// RUN: echo "skipping CHLO test with TanOp (see #954 for details)"

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = call @inputs() : () -> tensor<20x20xbf16>
    %1 = call @expected() : () -> tensor<20x20xbf16>
    %2 = chlo.tan %0 : tensor<20x20xbf16> -> tensor<20x20xbf16>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<20x20xbf16>, tensor<20x20xbf16>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> tensor<20x20xbf16> {
    %0 = stablehlo.constant dense<"0x81406CC0A93F0940BC3D1CC0334062C0AF3ED7BD83C01640153FA03F8ABE0F40A4409EC0DA3F44BF4AC0F03EEC3CD23EC73F2140A33F9EBFD2BF0440AEC008BF36C0A84047402E4034BF4CBF0740F03E07BF333F0940DB3D3DC0CC40FA3F79C009C10A3F9A3E65BFB3BE7E406A3D9DC0904037C04940F83F0E409D405BC0974077BFD73FD13F463F2B40BF40F4BFB8401F3F08BFBABF58C0EABFEFBF823FD4BF89C08E40B9BE58C0A7C00E40DD3E7E409DC08EBF42C091C082C0B63F64408A407F3E0CC0343FEA4006C0C13E3840A8C006C061C046BFB7BF28BF0C40A43B5D40D1BF47C0BD4005C08940534074BE5E3F143E77C0A53FC2BF4D40BE3FD4BFF23F5BBF8C3F9D3F5B40F2BF6AC0D9BF1CC06DBF2F3F4CC08B3FC93F14BF4540703F4C404BBF933F683E9C3F67BF0E4043BFE7402B3FCF3D5FC0BEBFE83F6FC0C53F37404B3FB23E35C085BF5040EBBF89C097BFB93F8FBF2FC066BFC2BFB8BFAD403740323FAD3FCBBF5F4088BF2DBF6FC0E0BF6F409EC0F9BFFD3F27C003C02C40B6C08B40C840003F12406340CA3D284012BE863F11C00EC05AC002C0F03F5C3E4BBF34BD4AC0733FD2BF3B40A03F7E409540B2C0DE3F8540374048BE5FBFA7BF61405140D3BF9EC0C1406D3F21409D4039408A3F044084BFD43E37BE883F8D3F0B40CE3FFE3F0C4013C030C089BF25400C40703F5140584029C0EABF2840704005C0723F94BF35C044BEA63F87BFA63DE7BEF0BF7BC0FEBE38C0B73F47BF24C05E403FBFCABFA53F8AC0034040BE84BF4B404740734084BFAD4024C0CEBF1340B53F45C07E408D40A33FCC3D12406940B7BDB73FD83F43BFE6C0C33FF93E903F8040A93FCCC03340B93F334063C02BC088C00E3F0A3F29C0F4BF823E97408340D7BF1940A4C0EE3E03404D3FFFC06BBEB4C0203F37BEEA3F7840A7BFA8BD8BC09940834050BD05C049408FC0D83F15C08B3FB63F8440A24071C02FC021BF87C04EC0C540CC3E90407140F2BE21BF8C40B23F5DBFDA3C403F26BF9DC0F8BFC5BF8AC0934090408EBC6CC0A1406340B2C089BFB03F42C03CBEAE3E06C0D03E66407F406AC0BCBFC0C08FC041C0CBBF4D3D65C0F83E40C0A73E1340F63FF33FDBBF"> : tensor<20x20xbf16>
    return %0 : tensor<20x20xbf16>
  }
  func.func private @expected() -> tensor<20x20xbf16> {
    %0 = stablehlo.constant dense<"0x9E3F1CBF7A40C8BFBD3D593FB8BED2BEB63ED8BDB4BF83BF283F41408DBEA4BF12C08C40F0C076BF70BC023FEC3CDF3E784239BF514037C06541EFBF903F16BF9D3ED7BF04BDE6BE59BF83BFD6BF023F15BF573FC8BFDC3D433EBD3D1FC06EBF953F193F9F3EA0BFBBBE8B3F6A3DA3409440943E7EBA27C0A9BFA3C093BE1DC3B9BF12C181C17A3F02BFA7BE384017BF373F16BF07C173BE73405240CE3F3B410BC06340C1BE73BEE73FA9BFEC3E8B3FA34001C0E33DAFC0A8BFD540E53E1740823EB53F593FD53FDE3FCB3E8CBED73FDE3FC9BE7ABFE1C045BFB5BFA43BA53E8141043DCBBEE63F0B40203E79BE973F153E60BF5D4091C17C3D39413B4141C093BFF83F3340933E414011BF0041593FAABF513F3CBDF33F014527BF82BDAE3F3C3D82BF0E406C3E2E40A2BFA9BF74BFAE3F4A3FD03DB7BE39C182C02CBFFC4194BE823FBA3EA63EDABFDF3D6C400BC01BC0FE4003C0DD3EA1BF91C1EFC09ABF94BE563F90408442B73EE6BF4DBF2CBFB1402C3F8C40234015C0173FF83FFABE2E3F264008BD0C3F95BFDC3ECB3D11BF13BEDE3F9A3FA93F8BBE01404CC05F3E82BF34BD70BCB33F654165BE41408B3F8E41613FC2C0CE3F94BE4BBE98BF6BC0C93EFF3D4E418C4084BEAA3F39BFA3C083BEEE3FEFBFD6BFE13E39BEE63FFC3FBBBFCFC112C0B5BF903FD33EEABF22BFB5BFAE3FFF3D733E0C3F734011BF323FE63FB13F11C0A63E46BE6440E2BFA63DF8BE4C407DBF0BBF8C3EE1407CBF273FAE3E6DBF08435D4017C0F8BF42BED6BFF83C04BD453FD6BF9ABF273FCF4190BFCA40823D8B3F4A405140CD3D95BF0C3FB7BDE14008C174BFA3BFA941073F0640943F7A40BDBDB8BEFE40B8BEDCBE023F00C01F3F193F0C3F3840853E1DC3B43F12416FBF1240003FF8BF843F0B416FBE463F393F39BE73C0673F6BC0A8BD26C068C1B43F50BDE63F7EBA81C008C1873FF33FD540C03F2FC038BFDD3E3ABFEEBF9EBD03BED83E9440383F03BF3ABF3640B04096BFDA3C6E3F42BFA3402740FCC117C0064194408EBC1CBF42C0DC3E613FEABFA140E33D3EBEB53EDE3FDC3EF93E903F11BF1CC1953E81C0023E84424D3DEFBE073F123EAD3E90BF2FC03CC0E340"> : tensor<20x20xbf16>
    return %0 : tensor<20x20xbf16>
  }
}