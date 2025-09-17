; ModuleID = '<stdin>'
source_filename = "/home/bsg13/cmpt479/Ex5/se-fault-tolerant-template/test/c/store-local-byte-array.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@__const.storeByte.bytes = private unnamed_addr constant [5 x i8] c"\03\05\07\09\0B", align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i64 @storeByte(i32 noundef %0, i8 noundef zeroext %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i8, align 1
  %5 = alloca [5 x i8], align 1
  %6 = alloca i64, align 8
  %7 = alloca i32, align 4
  store i32 %0, ptr %3, align 4
  store i8 %1, ptr %4, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %5, ptr align 1 @__const.storeByte.bytes, i64 5, i1 false)
  %8 = load i8, ptr %4, align 1
  %9 = load i32, ptr %3, align 4
  %10 = zext i32 %9 to i64
  %11 = getelementptr inbounds nuw [5 x i8], ptr %5, i64 0, i64 %10
  store i8 %8, ptr %11, align 1
  store i64 0, ptr %6, align 8
  store i32 0, ptr %7, align 4
  br label %12

12:                                               ; preds = %24, %2
  %13 = load i32, ptr %7, align 4
  %14 = icmp ult i32 %13, 5
  br i1 %14, label %15, label %27

15:                                               ; preds = %12
  %16 = load i64, ptr %6, align 8
  %17 = mul i64 3, %16
  %18 = load i32, ptr %7, align 4
  %19 = zext i32 %18 to i64
  %20 = getelementptr inbounds nuw [5 x i8], ptr %5, i64 0, i64 %19
  %21 = load i8, ptr %20, align 1
  %22 = zext i8 %21 to i64
  %23 = add i64 %17, %22
  store i64 %23, ptr %6, align 8
  br label %24

24:                                               ; preds = %15
  %25 = load i32, ptr %7, align 4
  %26 = add i32 %25, 1
  store i32 %26, ptr %7, align 4
  br label %12, !llvm.loop !6

27:                                               ; preds = %12
  %28 = load i64, ptr %6, align 8
  ret i64 %28
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #1

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
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
