; ModuleID = '<stdin>'
source_filename = "/home/bsg13/cmpt479/Ex5/se-fault-tolerant-template/test/c/store-global-byte.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@bytes = dso_local global [5 x i8] c"\03\05\07\09\0B", align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i64 @storeByte(i32 noundef %0, i8 noundef zeroext %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i8, align 1
  %5 = alloca i64, align 8
  %6 = alloca i32, align 4
  store i32 %0, ptr %3, align 4
  store i8 %1, ptr %4, align 1
  %7 = load i8, ptr %4, align 1
  %8 = load i32, ptr %3, align 4
  %9 = zext i32 %8 to i64
  %10 = getelementptr inbounds nuw [5 x i8], ptr @bytes, i64 0, i64 %9
  store i8 %7, ptr %10, align 1
  store i64 0, ptr %5, align 8
  store i32 0, ptr %6, align 4
  br label %11

11:                                               ; preds = %23, %2
  %12 = load i32, ptr %6, align 4
  %13 = icmp ult i32 %12, 5
  br i1 %13, label %14, label %26

14:                                               ; preds = %11
  %15 = load i64, ptr %5, align 8
  %16 = mul i64 3, %15
  %17 = load i32, ptr %6, align 4
  %18 = zext i32 %17 to i64
  %19 = getelementptr inbounds nuw [5 x i8], ptr @bytes, i64 0, i64 %18
  %20 = load i8, ptr %19, align 1
  %21 = zext i8 %20 to i64
  %22 = add i64 %16, %21
  store i64 %22, ptr %5, align 8
  br label %23

23:                                               ; preds = %14
  %24 = load i32, ptr %6, align 4
  %25 = add i32 %24, 1
  store i32 %25, ptr %6, align 4
  br label %11, !llvm.loop !6

26:                                               ; preds = %11
  store i8 3, ptr @bytes, align 1
  store i8 5, ptr getelementptr inbounds ([5 x i8], ptr @bytes, i64 0, i64 1), align 1
  store i8 7, ptr getelementptr inbounds ([5 x i8], ptr @bytes, i64 0, i64 2), align 1
  store i8 9, ptr getelementptr inbounds ([5 x i8], ptr @bytes, i64 0, i64 3), align 1
  store i8 11, ptr getelementptr inbounds ([5 x i8], ptr @bytes, i64 0, i64 4), align 1
  %27 = load i64, ptr %5, align 8
  ret i64 %27
}

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

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
