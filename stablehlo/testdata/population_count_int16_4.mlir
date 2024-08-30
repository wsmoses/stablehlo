// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<4xi16> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0 = call @inputs() : () -> tensor<4xi16>
    %1 = call @expected() : () -> tensor<4xi16>
    %2 = stablehlo.popcnt %0 : tensor<4xi16>
    stablehlo.custom_call @check.expect_eq(%2, %1) {has_side_effect = true} : (tensor<4xi16>, tensor<4xi16>) -> ()
    return %2 : tensor<4xi16>
  }
  func.func private @inputs() -> (tensor<4xi16> {mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<[-1, -2, 0, 1]> : tensor<4xi16>
    return %c : tensor<4xi16>
  }
  func.func private @expected() -> (tensor<4xi16> {mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<[16, 15, 0, 1]> : tensor<4xi16>
    return %c : tensor<4xi16>
  }
}