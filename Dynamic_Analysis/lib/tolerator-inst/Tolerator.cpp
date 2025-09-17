

#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Transforms/Utils/ModuleUtils.h"
#include "Tolerator.h"


using namespace llvm;
using tolerator::Tolerator;


namespace tolerator {

char Tolerator::ID = 0;

}


bool Tolerator::runOnModule(Module& m) {
  auto& context = m.getContext();
  auto* voidTy = Type::getVoidTy(context);
  auto* int32Ty = Type::getInt32Ty(context);
  auto* int64Ty = Type::getInt64Ty(context);
  auto* int8Ty = Type::getInt8Ty(context);
  auto* int8PtrTy = PointerType::getUnqual(int8Ty);
  auto* int1Ty = Type::getInt1Ty(context);
  auto dataLayout = m.getDataLayout();

  // All Functions from Runtime
  auto trackGlobalFunc = m.getOrInsertFunction("ToLeRaToR_trackGlobal", FunctionType::get(voidTy, {int8PtrTy, int32Ty}, false));
  auto trackMallocFunc = m.getOrInsertFunction("ToLeRaToR_trackmalloc", FunctionType::get(voidTy, {int8PtrTy, int32Ty}, false));
  auto trackFreeFunc = m.getOrInsertFunction("ToLeRaToR_trackfree", FunctionType::get(voidTy, {int8PtrTy}, false));
  auto trackallocFunc = m.getOrInsertFunction("ToLeRaToR_trackalloc", FunctionType::get(voidTy, {int8PtrTy, int32Ty}, false));
  auto functionEnter = m.getOrInsertFunction("ToLeRaToR_functionEnter", voidTy);
  auto functionExit = m.getOrInsertFunction("ToLeRaToR_functionExit", voidTy);
  auto divzero = m.getOrInsertFunction("ToLeRaToR_divzero", voidTy);
  auto readerror = m.getOrInsertFunction("ToLeRaToR_readerror", voidTy);
  auto freeerror = m.getOrInsertFunction("ToLeRaToR_freeerror", voidTy);
  auto writeerror = m.getOrInsertFunction("ToLeRaToR_writeerror", voidTy);
  auto isMemoryAllocated = m.getOrInsertFunction("ToLeRaToR_isMemoryAllocated", FunctionType::get(int1Ty, {int8PtrTy}, false));
  auto isMemoryValid = m.getOrInsertFunction("ToLeRaToR_isMemoryValid", FunctionType::get(int1Ty, {int8PtrTy}, false));
  auto isTask4 = m.getOrInsertFunction("ToLeRaToR_shouldExitWithDefault",FunctionType::get(int1Ty, false));
  auto isTask3 = m.getOrInsertFunction("ToLeRaToR_shouldDefaultInstruction",FunctionType::get(int1Ty, false));

  new GlobalVariable(m, int32Ty, true, GlobalValue::ExternalLinkage, ConstantInt::get(int32Ty, static_cast<int>(this->type), false), "ToLeRaToR_analysisType");

  // malloc anf free functions
  auto mallocCallee = m.getOrInsertFunction("malloc", FunctionType::get(int8PtrTy, {int64Ty}, false));
  auto freeCallee = m.getOrInsertFunction("free", FunctionType::get(voidTy, {int8PtrTy}, false));

  Function* mallocFn = dyn_cast<Function>(mallocCallee.getCallee());
  Function* freeFn = dyn_cast<Function>(freeCallee.getCallee());

  std::vector<Instruction*> mallocInstructions;
  std::vector<Instruction*> freeInstructions;
  std::vector<Instruction*> allocaInstructions;
  std::vector<Instruction*> divideInstructions;
  std::vector<Instruction*> loadInstructions;
  std::vector<Instruction*> storeInstructions;
  std::vector<Instruction*> functionStart;
  std::vector<Instruction*> functionEnd;

  // Go through the full module and find all the instruction before instrumenting
  // otherwise it gets stuck in a infinite loop when instrumentation is done while exploring
  for (Function& F : m) {
    if (F.isDeclaration()) continue;
    Instruction& inst = F.getEntryBlock().front();
    functionStart.push_back(&inst);

    for (BasicBlock& bb : F) {
      Instruction* terminator = bb.getTerminator();
      if (isa<ReturnInst>(terminator)) functionEnd.push_back(terminator);

      for (Instruction& inst : bb) {
        if (auto* callInst = dyn_cast<CallInst>(&inst)) {
          Function* calledFunc = callInst->getCalledFunction();
          if (!calledFunc) continue;
          if (calledFunc == mallocFn) mallocInstructions.push_back(&inst);
          else if (calledFunc == freeFn) freeInstructions.push_back(&inst);
        } else if (isa<AllocaInst>(&inst)) {
          allocaInstructions.push_back(&inst);
        } else if (auto* op = dyn_cast<BinaryOperator>(&inst)) {
          if (op->getOpcode() == Instruction::SDiv || op->getOpcode() == Instruction::UDiv || op->getOpcode() == Instruction::FDiv) {
            divideInstructions.push_back(&inst);
          }
        } else if (isa<LoadInst>(&inst)) {
          loadInstructions.push_back(&inst);
        } else if (isa<StoreInst>(&inst)) {
          storeInstructions.push_back(&inst);
        }
      }
    }
  }

  // Track globals for memory validization
  for (GlobalVariable& gv : m.globals()) {
    if (gv.isDeclaration() || gv.getName().starts_with("llvm.")) continue;
    IRBuilder<> builder(&*m.getFunctionList().begin()->getEntryBlock().getFirstInsertionPt());
    Value* gvPtr = builder.CreateBitCast(&gv, int8PtrTy);
    auto size = dataLayout.getTypeAllocSize(gv.getValueType());
    Value* sizeVal = ConstantInt::get(int32Ty, size);
    builder.CreateCall(trackGlobalFunc, {gvPtr, sizeVal});
  }
  // Track the mallocs to check for valid heap memory and size for spatial safety
  for (auto* inst : mallocInstructions) {
    auto* callInst = cast<CallInst>(inst);
    IRBuilder<> builder(callInst->getNextNode());
    Value* mallocPtr = builder.CreateBitCast(callInst, int8PtrTy);
    Value* sizeOfMalloc = callInst->getArgOperand(0);
    Value* sizeAsInt = builder.CreateTruncOrBitCast(sizeOfMalloc, int32Ty);
    builder.CreateCall(trackMallocFunc, {mallocPtr, sizeAsInt});
  }
  // Track the frees to insure spatial safety and track invalid access also handle invalid free
  for (auto* inst : freeInstructions) {
    // checks if the memory address was malloced before
    auto* callInst = cast<CallInst>(inst);
    IRBuilder<> builder(callInst);
    Value* voidptr = builder.CreateBitCast(callInst->getArgOperand(0), int8PtrTy);
    Value* isValid = builder.CreateCall(isMemoryAllocated, {voidptr});

    BasicBlock* currBB = callInst->getParent();
    Function* func = currBB->getParent();
    // creates different basic blocks to seperate the free call into its own basic block
    BasicBlock* doFreeBB = currBB->splitBasicBlock(BasicBlock::iterator(callInst), "dofree");
    BasicBlock* contBB = doFreeBB->splitBasicBlock(std::next(doFreeBB->getFirstNonPHIIt()), "afterfree");
    BasicBlock* errBB = BasicBlock::Create(context, "invalidfree", func, contBB);

    currBB->getTerminator()->eraseFromParent();
    builder.SetInsertPoint(currBB);
    // goto branch doFree if free is valid else into err branch
    builder.CreateCondBr(isValid, doFreeBB, errBB);

    // call freeerror in err branch
    // freeerror calls exit(-1) if the analysis type is LOGGING
    // then checks for type BYPASSING for task 4
    // don't need to check for IGNORING or DEFAULTING since they both work the same way in this case
    builder.SetInsertPoint(errBB);
    builder.CreateCall(freeerror);
    Value* task4 = builder.CreateCall(isTask4);
    BasicBlock* exitBB = BasicBlock::Create(context, "task4exit", func);
    BasicBlock* afterErrBB = BasicBlock::Create(context, "nottask4", func, contBB);

    builder.CreateCondBr(task4, exitBB, afterErrBB);

    // returns the function if BYPASSING with default value
    builder.SetInsertPoint(exitBB);
    if (func->getReturnType()->isVoidTy()) {
        builder.CreateCall(functionExit);
        builder.CreateRetVoid();
    } else {
        Value* defaultValue = Constant::getNullValue(func->getReturnType());
        builder.CreateCall(functionExit);
        builder.CreateRet(defaultValue);
    }

    // After error branch continues to the instruction after the free
    builder.SetInsertPoint(afterErrBB);
    builder.CreateBr(contBB);

    builder.SetInsertPoint(&*doFreeBB->getFirstInsertionPt());
    builder.CreateCall(trackFreeFunc, {voidptr});
  }
  // checks the stores for spatial safety
  for (auto* inst : storeInstructions) {
    auto* store = cast<StoreInst>(inst);
    IRBuilder<> builder(store);
    Value* i8ptr = builder.CreateBitCast(store->getPointerOperand(), int8PtrTy);
    Value* isValid = builder.CreateCall(isMemoryValid, {i8ptr});

    BasicBlock* currBB = store->getParent();
    Function* func = currBB->getParent();
    // seperate the store instruction into its own basicblock
    BasicBlock* doStoreBB = currBB->splitBasicBlock(BasicBlock::iterator(store), "dowrite");
    BasicBlock* contBB = doStoreBB->splitBasicBlock(std::next(doStoreBB->getFirstNonPHIIt()), "afterwrite");
    BasicBlock* errBB = BasicBlock::Create(context, "invalidwrite", func, contBB);

    currBB->getTerminator()->eraseFromParent();
    builder.SetInsertPoint(currBB);
    builder.CreateCondBr(isValid, doStoreBB, errBB);

    builder.SetInsertPoint(errBB);
    builder.CreateCall(writeerror);
    BasicBlock* exitBB = BasicBlock::Create(context, "task4exit", func);
    Value* task4 = builder.CreateCall(isTask4);
    builder.CreateCondBr(task4, exitBB, contBB);

    // task 4 handleing for return
    builder.SetInsertPoint(exitBB);
    if (func->getReturnType()->isVoidTy()) {
        builder.CreateCall(functionExit);
        builder.CreateRetVoid();
    } else {
        Value* retDefault = Constant::getNullValue(func->getReturnType());
        builder.CreateCall(functionExit);
        builder.CreateRet(retDefault);
    }
    // if its not task 1 or 4 its either 2 or 3
    // task 2 and 3 work the same for this so no need to check them
  }

  for (auto* inst : loadInstructions){
    auto* load = cast<LoadInst>(inst);
    BasicBlock* currBB = load->getParent();
    Function* func = currBB->getParent();

    IRBuilder<> builder(load);
    Value* voidptr = builder.CreateBitCast(load->getPointerOperand(), int8PtrTy);
    Value* isValid = builder.CreateCall(isMemoryValid, {voidptr});

    // Spliting basic blocks
    BasicBlock* doLoadBB = currBB->splitBasicBlock(BasicBlock::iterator(load), "doread");
    BasicBlock* contBB = doLoadBB->splitBasicBlock(std::next(doLoadBB->getFirstNonPHIIt()), "afterread");
    BasicBlock* invalidBB = BasicBlock::Create(context, "invalidread", func, contBB);
    BasicBlock* task4ExitBB = BasicBlock::Create(context, "task4exit", func);
    BasicBlock* notTask4BB = BasicBlock::Create(context, "nottask4", func, contBB);

    // Checking if memory access is valid
    currBB->getTerminator()->eraseFromParent();
    builder.SetInsertPoint(currBB);
    builder.CreateCondBr(isValid, doLoadBB, invalidBB);

    // checks if its task4
    builder.SetInsertPoint(invalidBB);
    builder.CreateCall(readerror);
    Value* isTask4Call = builder.CreateCall(isTask4);
    builder.CreateCondBr(isTask4Call, task4ExitBB,notTask4BB);

    //check if is task 3
    BasicBlock* task3BB = BasicBlock::Create(context, "task3", func, contBB);
    builder.SetInsertPoint(notTask4BB);
    Value* isTask3Call = builder.CreateCall(isTask3);
    // if not task 3 must be task 2, do load is never reached in this case because task 1,2,4 would exit already so must be task 3
    builder.CreateCondBr(isTask3Call, task3BB, doLoadBB);

    builder.SetInsertPoint(task3BB);
    builder.CreateBr(contBB);
    
    builder.SetInsertPoint(task4ExitBB);
    if (func->getReturnType()->isVoidTy()) {
      builder.CreateCall(functionExit);
      builder.CreateRetVoid();
    } else {
      Value* defaultRet = Constant::getNullValue(func->getReturnType());
      builder.CreateCall(functionExit);
      builder.CreateRet(defaultRet);
    }

    // check which block was done before contBB and use default value if it was task3BB
    builder.SetInsertPoint(&*contBB->getFirstInsertionPt());
    Value* defaultVal = Constant::getNullValue(load->getType());
    auto* phi = builder.CreatePHI(load->getType(), 2, "loadresult");
    auto* newLoad = load->clone();
    builder.SetInsertPoint(&*doLoadBB->getFirstInsertionPt());
    builder.Insert(newLoad);
    phi->addIncoming(newLoad, doLoadBB);
    phi->addIncoming(defaultVal, task3BB);
    load->replaceAllUsesWith(phi);
    load->eraseFromParent();
  }
  // Handle tracking stack memory for each function
  for (auto* inst : allocaInstructions) {
    auto* alloca = cast<AllocaInst>(inst);
    IRBuilder<> builder(alloca->getNextNode());
    Value* localPtr = builder.CreateBitCast(alloca, int8PtrTy);
    uint64_t size = dataLayout.getTypeAllocSize(alloca->getAllocatedType());
    builder.CreateCall(trackallocFunc, {localPtr, ConstantInt::get(int32Ty, size)});
  }
  // add a function call a start of each function to help manage the functions local memory
  for (auto* inst : functionStart) {
    IRBuilder<> builder(inst);
    builder.CreateCall(functionEnter);
  }
  // add a function call a end of each function to free the local memory
  for (auto* inst : functionEnd) {
    IRBuilder<> builder(inst);
    builder.CreateCall(functionExit);
  }

  for(auto* inst : divideInstructions){
    auto* op = dyn_cast<BinaryOperator>(inst);
    Value* denominator = op->getOperand(1);
    IRBuilder<> builder(op);

    Value* isZero = nullptr;
    // check if the opperation if float div or interger div
    if (op->getOpcode() == Instruction::FDiv) {
      isZero = builder.CreateFCmpOEQ(denominator, ConstantFP::get(denominator->getType(), 0.0));
    } else {
      isZero = builder.CreateICmpEQ(denominator, ConstantInt::get(denominator->getType(), 0));
    }

    BasicBlock* currBB = op->getParent();
    Function* func = currBB->getParent();
    //split basic blocks
    BasicBlock* doDivBB = currBB->splitBasicBlock(BasicBlock::iterator(op), "dodiv");
    BasicBlock* contBB = doDivBB->splitBasicBlock(std::next(doDivBB->getFirstNonPHIIt()), "afterdiv");
    BasicBlock* errBB = BasicBlock::Create(context, "divbyzero", func, contBB);
    BasicBlock* task4ExitBB = BasicBlock::Create(context, "task4exit", func);
    BasicBlock* notTask4BB = BasicBlock::Create(context, "nottask4", func, contBB);

    // Erase old terminator to insert new branches
    currBB->getTerminator()->eraseFromParent();
    IRBuilder<> condBuilder(currBB);
    condBuilder.CreateCondBr(isZero, errBB, doDivBB);

    // errBB: zero denominator detected
    builder.SetInsertPoint(errBB);
    builder.CreateCall(divzero);
    Value* isTask4Call = builder.CreateCall(isTask4);
    builder.CreateCondBr(isTask4Call, task4ExitBB,notTask4BB);

    //check if is task 3
    BasicBlock* task3BB = BasicBlock::Create(context, "task3", func, contBB);
    builder.SetInsertPoint(notTask4BB);
    Value* isTask3Call = builder.CreateCall(isTask3);
    // dodivBB never reached because task 1,2,4 already exit so must be task 3
    builder.CreateCondBr(isTask3Call, task3BB, doDivBB);

    builder.SetInsertPoint(task3BB);
    builder.CreateBr(contBB);



    // task4 exit block: call functionExit and return default value or void
    builder.SetInsertPoint(task4ExitBB);
    if (func->getReturnType()->isVoidTy()) {
      builder.CreateCall(functionExit);
      builder.CreateRetVoid();
    } else {
      Value* defaultRet = Constant::getNullValue(func->getReturnType());
      builder.CreateCall(functionExit);
      builder.CreateRet(defaultRet);
    }

    // PHI node in contBB to merge results
    builder.SetInsertPoint(&*contBB->getFirstInsertionPt());
    Value* defaultVal = Constant::getNullValue(op->getType());
    auto* phi = builder.CreatePHI(op->getType(), 2, "divresult");

    auto* newOp = op->clone();
    builder.SetInsertPoint(&*doDivBB->getFirstInsertionPt());
    builder.Insert(newOp);

    phi->addIncoming(newOp, doDivBB);
    phi->addIncoming(defaultVal, task3BB);

    op->replaceAllUsesWith(phi);
    op->eraseFromParent();

    }

  return true;
}

