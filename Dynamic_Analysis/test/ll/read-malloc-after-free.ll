; ModuleID = '<stdin>'
source_filename = "/home/bsg13/cmpt479/Ex5/se-fault-tolerant-template/test/c/read-malloc-after-free.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local zeroext i8 @readByte(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca i8, align 1
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca ptr, align 8
  store i32 %0, ptr %4, align 4
  store i32 %1, ptr %5, align 4
  %7 = call noalias ptr @malloc(i64 noundef 5) #3
  store ptr %7, ptr %6, align 8
  %8 = load ptr, ptr %6, align 8
  %9 = getelementptr inbounds i8, ptr %8, i64 0
  store i8 9, ptr %9, align 1
  %10 = load ptr, ptr %6, align 8
  %11 = getelementptr inbounds i8, ptr %10, i64 1
  store i8 11, ptr %11, align 1
  %12 = load ptr, ptr %6, align 8
  %13 = getelementptr inbounds i8, ptr %12, i64 2
  store i8 13, ptr %13, align 1
  %14 = load ptr, ptr %6, align 8
  %15 = getelementptr inbounds i8, ptr %14, i64 3
  store i8 17, ptr %15, align 1
  %16 = load ptr, ptr %6, align 8
  %17 = getelementptr inbounds i8, ptr %16, i64 4
  store i8 19, ptr %17, align 1
  %18 = load i32, ptr %5, align 4
  %19 = icmp ne i32 %18, 0
  br i1 %19, label %20, label %26

20:                                               ; preds = %2
  %21 = load ptr, ptr %6, align 8
  %22 = load i32, ptr %4, align 4
  %23 = zext i32 %22 to i64
  %24 = getelementptr inbounds nuw i8, ptr %21, i64 %23
  %25 = load i8, ptr %24, align 1
  store i8 %25, ptr %3, align 1
  br label %33

26:                                               ; preds = %2
  %27 = load ptr, ptr %6, align 8
  call void @free(ptr noundef %27) #4
  %28 = load ptr, ptr %6, align 8
  %29 = load i32, ptr %4, align 4
  %30 = zext i32 %29 to i64
  %31 = getelementptr inbounds nuw i8, ptr %28, i64 %30
  %32 = load i8, ptr %31, align 1
  store i8 %32, ptr %3, align 1
  br label %33

33:                                               ; preds = %26, %20
  %34 = load i8, ptr %3, align 1
  ret i8 %34
}

; Function Attrs: nounwind allocsize(0)
declare noalias ptr @malloc(i64 noundef) #1

; Function Attrs: nounwind
declare void @free(ptr noundef) #2

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nounwind allocsize(0) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nounwind allocsize(0) }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 20.1.4"}
