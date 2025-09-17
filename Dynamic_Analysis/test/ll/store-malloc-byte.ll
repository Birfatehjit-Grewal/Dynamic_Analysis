; ModuleID = '<stdin>'
source_filename = "/home/bsg13/cmpt479/Ex5/se-fault-tolerant-template/test/c/store-malloc-byte.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i64 @storeByte(i32 noundef %0, i8 noundef zeroext %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i8, align 1
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  %7 = alloca i32, align 4
  store i32 %0, ptr %3, align 4
  store i8 %1, ptr %4, align 1
  %8 = call noalias ptr @malloc(i64 noundef 5) #2
  store ptr %8, ptr %5, align 8
  %9 = load ptr, ptr %5, align 8
  %10 = getelementptr inbounds i8, ptr %9, i64 0
  store i8 3, ptr %10, align 1
  %11 = load ptr, ptr %5, align 8
  %12 = getelementptr inbounds i8, ptr %11, i64 1
  store i8 5, ptr %12, align 1
  %13 = load ptr, ptr %5, align 8
  %14 = getelementptr inbounds i8, ptr %13, i64 2
  store i8 7, ptr %14, align 1
  %15 = load ptr, ptr %5, align 8
  %16 = getelementptr inbounds i8, ptr %15, i64 3
  store i8 9, ptr %16, align 1
  %17 = load ptr, ptr %5, align 8
  %18 = getelementptr inbounds i8, ptr %17, i64 4
  store i8 11, ptr %18, align 1
  %19 = load i8, ptr %4, align 1
  %20 = load ptr, ptr %5, align 8
  %21 = load i32, ptr %3, align 4
  %22 = zext i32 %21 to i64
  %23 = getelementptr inbounds nuw i8, ptr %20, i64 %22
  store i8 %19, ptr %23, align 1
  store i64 0, ptr %6, align 8
  store i32 0, ptr %7, align 4
  br label %24

24:                                               ; preds = %37, %2
  %25 = load i32, ptr %7, align 4
  %26 = icmp ult i32 %25, 5
  br i1 %26, label %27, label %40

27:                                               ; preds = %24
  %28 = load i64, ptr %6, align 8
  %29 = mul i64 3, %28
  %30 = load ptr, ptr %5, align 8
  %31 = load i32, ptr %7, align 4
  %32 = zext i32 %31 to i64
  %33 = getelementptr inbounds nuw i8, ptr %30, i64 %32
  %34 = load i8, ptr %33, align 1
  %35 = zext i8 %34 to i64
  %36 = add i64 %29, %35
  store i64 %36, ptr %6, align 8
  br label %37

37:                                               ; preds = %27
  %38 = load i32, ptr %7, align 4
  %39 = add i32 %38, 1
  store i32 %39, ptr %7, align 4
  br label %24, !llvm.loop !6

40:                                               ; preds = %24
  %41 = load i64, ptr %6, align 8
  ret i64 %41
}

; Function Attrs: nounwind allocsize(0)
declare noalias ptr @malloc(i64 noundef) #1

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nounwind allocsize(0) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nounwind allocsize(0) }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 20.1.4"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
