
#include <cstdint>
#include <cstdio>
#include <cstdlib>

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

#include <unordered_map>
#include <vector>


extern "C" {


// This macro allows us to prefix strings so that they are less likely to
// conflict with existing symbol names in the examined programs.
// e.g. TOLERATE(entry) yields ToLeRaToR_entry
#define TOLERATE(X) ToLeRaToR_##X

extern int TOLERATE(analysisType);

void
TOLERATE(helloworld)() {
  printf("==============================\n"
         "\tHello, World!\n"
         "==============================\n");
}

void
TOLERATE(goodbyeworld)() {
  printf("==============================\n"
         "\tGoodbye, World!\n"
         "==============================\n");
}

  
struct MemoryRange {
    uintptr_t start;
    uintptr_t end;
};

static std::unordered_map<void*, MemoryRange> heap_map;
static std::unordered_map<void*, MemoryRange> global_map;
static std::vector<std::unordered_map<void*, MemoryRange>> alloc_map;

void TOLERATE(divzero)() {
    printf("FOUND: Division by zero\n");
    if (TOLERATE(analysisType) == 0 || TOLERATE(analysisType) == 1) exit(-1);
}

void TOLERATE(exit)() {
    exit(-1);
}

void TOLERATE(readerror)() {
    printf("FOUND: Invalid read from memory\n");
    if (TOLERATE(analysisType) == 0 || TOLERATE(analysisType) == 1) exit(-1);
}

void TOLERATE(freeerror)() {
    printf("FOUND: Invalid free of memory\n");
    if (TOLERATE(analysisType) == 0) exit(-1);
}

void TOLERATE(writeerror)() {
    printf("FOUND: Invalid write to memory\n");
    if (TOLERATE(analysisType) == 0) exit(-1);
}

void TOLERATE(functionEnter)() {
    alloc_map.emplace_back();
}

void TOLERATE(functionExit)() {
    if (!alloc_map.empty()) {
        alloc_map.pop_back();
    }
}

void TOLERATE(trackmalloc)(void* ptr, int size) {
    uintptr_t addr = reinterpret_cast<uintptr_t>(ptr);
    heap_map[ptr] = { addr, addr + static_cast<uintptr_t>(size) };
}

void TOLERATE(trackfree)(void* ptr) {
    heap_map.erase(ptr);
}

void TOLERATE(trackGlobal)(void* ptr, int size) {
    uintptr_t addr = reinterpret_cast<uintptr_t>(ptr);
    global_map[ptr] = { addr, addr + static_cast<uintptr_t>(size) };
}

void TOLERATE(trackalloc)(void* ptr, int size) {
    if (!alloc_map.empty()) {
        uintptr_t addr = reinterpret_cast<uintptr_t>(ptr);
        alloc_map.back()[ptr] = { addr, addr + static_cast<uintptr_t>(size) };
    }
}

bool TOLERATE(isMemoryAllocated)(void* ptr) {
    return heap_map.find(ptr) != heap_map.end();
}

bool TOLERATE(isMemoryValid)(void* ptr) {
    uintptr_t addr = reinterpret_cast<uintptr_t>(ptr);

    // Check heap
    for (const auto& [base, MemoryRange] : heap_map) {
        if (addr >= MemoryRange.start && addr < MemoryRange.end)
            return true;
    }

    // Check global
    for (const auto& [base, MemoryRange] : global_map) {
        if (addr >= MemoryRange.start && addr < MemoryRange.end)
            return true;
    }

    // Check stack
    for (auto it = alloc_map.rbegin(); it != alloc_map.rend(); ++it) {
        for (const auto& [base, MemoryRange] : *it) {
            if (addr >= MemoryRange.start && addr < MemoryRange.end)
                return true;
        }
    }

    return false;
}

bool TOLERATE(shouldDefaultInstruction)(){
  return TOLERATE(analysisType) == 2;
}

bool TOLERATE(shouldExitWithDefault)(){
  return TOLERATE(analysisType) == 3;
}


}
