// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<20x20xi8> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0:2 = call @inputs() : () -> (tensor<20x20xi8>, tensor<20x20xi8>)
    %1 = call @expected() : () -> tensor<20x20xi8>
    %2 = stablehlo.add %0#0, %0#1 : tensor<20x20xi8>
    stablehlo.custom_call @check.expect_eq(%2, %1) {has_side_effect = true} : (tensor<20x20xi8>, tensor<20x20xi8>) -> ()
    return %2 : tensor<20x20xi8>
  }
  func.func private @inputs() -> (tensor<20x20xi8> {mhlo.layout_mode = "default"}, tensor<20x20xi8> {mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<"0x07FF00FF02FF000600000100FF01FEFEFD03FF0800010605FEFF010300FD000702000004FEFF0003FC08FE03FB00FAFB00FE02FB00000100020200FE01FE0100020204000001FD01FDFDFA0002000402FF01030500FD0103000003FEFD000500FEFFFFFCFE0202F902030201FD00FC00FF03FAFF0302FEFEFFFF00FF00020000000200F70001010001FF00FF03FE01FE06010100FEFF0402FF0105FD0401FD00040000FF00FDFF01F9010300000202FD0101FC000100FEFE0003FF0005FF0100FBFEFAFFFB00FA0300000103000200000003000003FF06030003FDFE000004FF02FDFFFEFD00000200000002FCFEFEFF000202FB02FD0105FD0001000000FBFE0001FFFD00FEFC0000020302010000FF0000060002FF00FFFDFEFFFCFC0202FF03040001FFFF020100FFFF0100FFFF0103020106FF00000103000102060200FF00FA0002FF0701FFFFFF0200000300FF05FE00FC020002000203FF04000001FF00FFFD0400FBFDFAFEFE03FC02FE01FC02FF0701FD0002010200020000FE0002FF00040001FE01010101F7FC02FC0001"> : tensor<20x20xi8>
    %c_0 = stablehlo.constant dense<"0xFA00030002FF0003FF010300000002FD0202FE00FDFFFF00FFFFFE02FEFEFCFE00000000010001FEFF000700030301F90103FB02FF0203FCFFFF0100FC00FD020000FD01FEFF000200FF00FF0006FE010000FCFD01010000000302050000000000FEFDFF0100FF0107FEFD00FA01FC02FD0201020000FB02010200FCFC02FAFF00FBFF0200F8FC05000101FFFE0201FE04FEFEFB02000001000005FC00FB02FC00FFFAFF0000FFFE0200FDFF00FE0101FF01FA0107000103040401FE0001FFFE03FF03FD03FDFE0202FFFBFFFE080004FEFF0301FDFEFF0106FD0001030100000100FC040100FD0203FA050202FE00FEFF00FE0004040100FEFEFE00FA000500010000FF03FCFA00050201FF00F90100FF03020000FFFFFE03FAFEFE03FE000000010000FCFD0000010102020704FF0408FEFE02FEFC0401FD070002FD0201FF0405000506FEFB00000100080405FD06000005FEFFFF00FE020403FC02FFF900FE03FFFDFEFE0000010000FE0101FF02FEFDFFFF030003020603FF01FD020302010202FF00FDFEFE00FD000602FFFEFE"> : tensor<20x20xi8>
    return %c, %c_0 : tensor<20x20xi8>, tensor<20x20xi8>
  }
  func.func private @expected() -> (tensor<20x20xi8> {mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<"0x01FF03FF04FE0009FF010400FF0100FBFF05FD08FD000505FDFEFF05FEFBFC0502000004FFFF0101FB080503FE03FBF40101FDFDFF0204FC010101FEFDFEFE0202020101FE00FD03FDFCFAFF02060203FF01FF0201FE010300030503FD000500FEFDFCFBFF0201FA0901FF01F701F802FC05FB010302F900000100FBFC04FAFF00FDFFF900F9FD05010001FE010002FC0AFFFFFB00FF0403FF010AF904FCFFFC04FFFAFE00FDFEFFFB0100FF000003FE0002F6010800FF01040700FE050000FEFEFDFDFCFEFDF80502FFFC02FE0A0004FE02030100FD05040600FDFF030104FF03FDFB02FE00FD0403FA0504FEFCFEFDFF0200FB06010205FBFEFF00FA0000FE0101FFFC03FAF6000504040101F901FFFF03080002FEFFFD00F8FDFAFF0002FF03050001FBFC0201010001030703FE050B00FF08FDFC040200070104030401FE04FF00070505FCFFFF0002080408FD0505FE05FA01FF02FE0407020002FFFAFFFE02FC01FEF9FDFAFFFE03FA03FF00FE00FC06000000050308030101FD000304000206FF01FBFFFF01FEF70204FBFEFF"> : tensor<20x20xi8>
    return %c : tensor<20x20xi8>
  }
}