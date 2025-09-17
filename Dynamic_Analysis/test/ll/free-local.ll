; ModuleID = '<stdin>'
source_filename = "/home/bsg13/cmpt479/Ex5/se-fault-tolerant-template/test/c/free-local.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@__const.tryFree.local = private unnamed_addr constant [5 x i8] c"\03\05\07\09\0B", align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i64 @tryFree(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca [5 x i8], align 1
  %4 = alloca ptr, align 8
  store i32 %0, ptr %2, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %3, ptr align 1 @__const.tryFree.local, i64 5, i1 false)
  %5 = call noalias ptr @malloc(i64 noundef 5) #4
  store ptr %5, ptr %4, align 8
  %6 = load i32, ptr %2, align 4
  %7 = icmp ne i32 %6, 0
  br i1 %7, label %8, label %10

8:                                                ; preds = %1
  %9 = load ptr, ptr %4, align 8
  br label %12

10:                                               ; preds = %1
  %11 = getelementptr inbounds [5 x i8], ptr %3, i64 0, i64 0
  br label %12

12:                                               ; preds = %10, %8
  %13 = phi ptr [ %9, %8 ], [ %11, %10 ]
  call void @free(ptr noundef %13) #5
  %14 = load ptr, ptr %4, align 8
  %15 = ptrtoint ptr %14 to i64
  ret i64 %15
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: nounwind allocsize(0)
declare noalias ptr @malloc(i64 noundef) #2

; Function Attrs: nounwind
declare void @free(ptr noundef) #3

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { nounwind allocsize(0) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { nounwind allocsize(0) }
attributes #5 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 20.1.4"}
