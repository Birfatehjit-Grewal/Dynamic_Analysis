; ModuleID = '<stdin>'
source_filename = "/home/bsg13/cmpt479/Ex5/se-fault-tolerant-template/test/c/read-local-after-return.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@__const.readByteHelper.bytes = private unnamed_addr constant [5 x i8] c"\09\0B\0D\11\13", align 1
@__const.readByte.bytes = private unnamed_addr constant [5 x i8] c"\09\0B\0D\11\13", align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local ptr @readByteHelper(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca [5 x i8], align 1
  store i32 %0, ptr %2, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %3, ptr align 1 @__const.readByteHelper.bytes, i64 5, i1 false)
  %4 = load i32, ptr %2, align 4
  %5 = zext i32 %4 to i64
  %6 = getelementptr inbounds nuw [5 x i8], ptr %3, i64 0, i64 %5
  ret ptr %6
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local zeroext i8 @readByte(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca i8, align 1
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca [5 x i8], align 1
  store i32 %0, ptr %4, align 4
  store i32 %1, ptr %5, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %6, ptr align 1 @__const.readByte.bytes, i64 5, i1 false)
  %7 = load i32, ptr %5, align 4
  %8 = icmp ne i32 %7, 0
  br i1 %8, label %9, label %14

9:                                                ; preds = %2
  %10 = load i32, ptr %4, align 4
  %11 = zext i32 %10 to i64
  %12 = getelementptr inbounds nuw [5 x i8], ptr %6, i64 0, i64 %11
  %13 = load i8, ptr %12, align 1
  store i8 %13, ptr %3, align 1
  br label %18

14:                                               ; preds = %2
  %15 = load i32, ptr %4, align 4
  %16 = call ptr @readByteHelper(i32 noundef %15)
  %17 = load i8, ptr %16, align 1
  store i8 %17, ptr %3, align 1
  br label %18

18:                                               ; preds = %14, %9
  %19 = load i8, ptr %3, align 1
  ret i8 %19
}

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 20.1.4"}
