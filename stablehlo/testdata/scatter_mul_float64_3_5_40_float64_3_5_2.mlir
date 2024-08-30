// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<3x5x40xf64> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<1> : tensor<2x1xi64>
    %0:2 = call @inputs() : () -> (tensor<3x5x40xf64>, tensor<3x5x2xf64>)
    %1 = call @expected() : () -> tensor<3x5x40xf64>
    %2 = "stablehlo.scatter"(%0#0, %c, %0#1) <{scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 1], inserted_window_dims = [2], scatter_dims_to_operand_dims = [2], index_vector_dim = 1>}> ({
    ^bb0(%arg0: tensor<f64>, %arg1: tensor<f64>):
      %3 = stablehlo.multiply %arg0, %arg1 : tensor<f64>
      stablehlo.return %3 : tensor<f64>
    }) : (tensor<3x5x40xf64>, tensor<2x1xi64>, tensor<3x5x2xf64>) -> tensor<3x5x40xf64>
    stablehlo.custom_call @check.expect_close(%2, %1) {has_side_effect = true} : (tensor<3x5x40xf64>, tensor<3x5x40xf64>) -> ()
    return %2 : tensor<3x5x40xf64>
  }
  func.func private @inputs() -> (tensor<3x5x40xf64> {mhlo.layout_mode = "default"}, tensor<3x5x2xf64> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x50DD2297E3030B40211B8CEAC6BBE8BF8B3001FE2394DA3FED50BE22651BF4BF8E4CCB459CECD53F3E329980244C1640127B235D791E12C056234D513F092640387EDB7E23630B40B9F24C65392AE33F062A0BA189B615402FE50D5E51C001406AB49C61FA3708407C5575046AA204C05E89DD9708B702C0E87AB40A81280C4038631ACA49CE05C0819096592C7707C0BEDDA1C0FAA107C03C3DF1F25EDE02400368B523D2C510C0E0A44BC35DE6B4BF0C7367394AA01AC02B93216E72A4DF3F2B2AA20AA4F7F6BFB5C2B3D8B5420140D81A6DCE7EECF73F92902FA6CE73EDBF24A3BAD5EB60F5BF3E965C98434AF43F4A5BFB5C11250CC0B4FA7FC2EFA9EB3FF2CA73EA168916C04038195E2DA807C0F6A8BAD5C2BDEF3FCAD329AAE623054062A6AE6BDE4E0A40F46519F697DCCD3F8619494E9C4CDBBF4824635284FFF03F05C45BA9637F0E407858DEF0AA6102400EC8008DD39009C07858D40562E600C0E2D9B13FD9571140AA844A7F5FAADABFF2C3D736F09B19C0FE2702357B801C40BCBBE6D8D7160240BE07DFA8391DFABF1CF3AC138C0C1A4000DEE35D518B1240316BC9CE81E0FD3FF19A93F49C86E23FEF488A4A298EF5BF7AFC5A3D13D8084058AB826CD7F1FBBFFB4E2E319A9DFBBFC5A657CBBD651540A8CBC42B07C71340A8284C495CFB05C0122187585B46F7BFC88C9A29B6DF0540086CEC4F49D5F93F04E5D7B664EF114040184C614F32DD3F245B39DB0A920640DCA5CBA2885B124039D74DC17658F03FBDA21109C562E53F6A039F49DA46FE3FE8598DAB85C50C40CCC5131C1562ED3FDC110C240855E13FC00D4705FED908C0CAF87A1D1A4E02C07EC296001EBBFE3F543BFEEE6D4903407636EC7D848E09C03CFEC3B54952EF3F4081ACBD3DF00BC036E7A1E9B16602407C9EC28425A3F0BFAE294F1AA3E316C0BE609F5C943205C0C2B5F9E2811FCABF728037903A221D40903A1A0D12981440BAC74F649832F13FFB683132BC46E13F4E20C368B6ECF23FBCAC737AFF7208C02A4F3605D647F63F55C2F3D05065F5BFF5282237D9B9DC3F4960A9C23671E4BFBFBD0E8686C4F13FDC2381BABFA0C8BFFB3D2A575C59FA3FA4392D92C71EFF3F1BA3299E4341D23F80758595426BF73FD8ED16E8433514400AB093DD089FF7BF96DD9FA6B727B43F686D6C10EB4120C0ECAAC57138560440F915D639BEA6E2BFCC89BF08BD5205C00E9D0B22B438DDBF94B8D80D77D7F73FC18C6266FF8DCC3F7E8A1D9673A614C01CF3CCBC51FCEB3FECAA21F73435DB3F113B4E8BEBCCEBBFCF10BE9806560440280552C1EA0BC93F0C256BC081D0FABFBBEE4BB7F7AAF33F78BAF59FB23D0A40C70D3AF1057DE5BFB0E4A6309001084054DF7148A7F1F73F25C2CD2702CA11C0284152E77E12F63FEA949528A750633FCE1DCABF2B2909C0FE45E0F671BF054011190394997DB43FE1F7A889FA650240DFB3FDD724191240382E058F22741BC0088A33507F2005408F1A4CF55390B7BF62FF2F13D6190E40375139D0194EEBBFEC65200CF2F3F4BFD8B8E5260192FF3F92C65A234C8F0040DBD3CBBD2B2D12C00491F83C1CE31140AD8AB3A58E16FB3F4A35A23ADF671140E8E56CF6F98B0DC03047DBB8B034FCBFB2DEE934349E0D407E42E16963C3F63F8DE466AAD8C70840C3818965BA3612C026A5AC53F425F63FF6850803E8FD044072153AF1542D07C0BE8D99EA5D21F13F5EAF6924ABD5C13FA2858B0D113B1340CA3289DCD646F13F2A6F9D210B9800C000152C8E0E910340E8CD2867BA1D0C40A678445F8B9709C09C49B9D07B95E93FDCB69D6BC97702C04B1A6B9BA10111C01A189ED71FB3F2BF90E759B27FFBF7BFAA5C7E2F65DBF53FA690582C74C913C0C02C614CF0D213C0F48529EDB019F53F9A40045CA22B04C01D84980AB07A02401AA2A67BD74E0EC0FE30C55B88A801404E3F6D5829651040888EE974A290EA3F56260DB6040504C032036785640602C029913C12553F10C0C39C40D87ECA10402791FA264A2215C06AC0B153578AFF3F856350576907FA3F509ADCD3CBE90D40D3150A4F452AE7BF7066E062A84BDF3F888232927A04074007A1AC1EC51B21C0F44A224A7C2F0040985A4305BB86174017C38CC106E103C03BC3A2DC1C6FF5BF101B6997D88C01C0844FA2362538F5BFE7DAEE0A479801C07DD3635C684CE73F9375396795451340D46E10F0CE3F174054A8B2944F1310C0F6BC57481A4C08C0AD764C80AB2013C01834FD8CE9FB1B40C44D479F9F03F1BF12E76A145B38014020A3C96473BBD7BF5AFB92AF9913E1BFC44C8A88A4C5F7BFBAE058E318C0D43FEAFF469EEE8910C0AC531D203C03FA3F2D4B8447D22EC03F60E0E60942E2E13F82D48369EEF8B73F44F3F387260DD0BF90D0E272C5DF0D401003922F7AB30CC06C93DFF03E940BC05B33A361A38DF2BF6384F0A088A807C04286A6E64D7C02C0A2BC0154F1BEE93FB80980C4A627E23F340865E66DF6FEBF98A6BBBC76A51340B6885446DD081840BF785DE379B31A40AF19E6D6AD8302C04618F5F923F6D9BF08BA7A910FA9FFBF91F44CFB251508404566C8ED31EBF1BF74DE904644BF1240CE4F5B229483EF3FE221E4736BCD0340FEEFBE96BADA0B402DCC9864E471F7BF6F8593DC26220CC0A93CBB7DDCD1C43F76C6CC15FB8611C0942B149CA13200C0550863C047D20C40BC440E3B8E12F7BFE863ADCF44DAF03FB5D49DA0C3721940E296533F8D08134071147BFC652CF53FA20A4FB918C207C0FB1E2D06473406C07828CC113D6F18C0930F96657FA612404159600267A8E23F8A5108B860970340162C7FDB598914404409683ECF37ECBF6565F791919E08C02B7986AFF83F1240B7025D2AE2B2E0BFFA459F640BA6FA3F591DA16EAFB21040FE236EC667CD03C0FC66DCB94784F13F14FDEC0BBC8A1040B652433AC467C6BF4909C67A544E16C0372F8659D756FC3FA68C27C711F30440D55419E2379C0BC0A4196D28095A12C009EF230E8D15FE3F6620CE0CA7141D406FAF5209C89D09407298E4AE77F511C013B9FA5AB8BE00C0B39A8AFF8F2F923F16490BE58254E1BFCB45BA06A7B907C0B6C63D3632AE00C0F24119884D88EEBF1F6CB33EFC54EF3FF43E544F1DB8C2BF52A3A439B48C1540B2B142CA6F75EE3F729FEF1551AE0F4028D1BFD4655912C07AC8A583A31EF0BF54FEDFEFD4C0FA3F46CB28410155ADBFB0B29333FF46ECBF0E19FDC6ABCE08C0EE8F764DF5BE174053DDDAF404220540C0995D87653F1240E14E2D35D387F13FC550E40B724AE4BFAAAC29029089EBBF1C1EC2CCF72610401E2C03018FDADBBF752EFC92CF5F1240A83DAE5248B50D405919059A358D11C0661799410591E83F31BF0B81C6A50640A273B279BC7CBC3F50386CA7DB08F4BF2044FC09AD5401405844BE61D5CBFDBF393A6357F62005C0433DE1ECCB4113C0D8B4FCA2970CD6BF233EBE65D45901C0413696C77DB807C0BA5013587D01FB3FA9CBBD219F4600C08DCF1036375D0FC0E2E852BC2C6AAB3F771287D9D28107401235EF83CE26F5BFB2EA6DB78C3FDC3FD31E195F337B06403C8246DA080B09C06FADF133F8BFF53FB2A1657195BE0FC00C48D73D85370E408E6484CBC16DF73F7E311A945F69DC3FF14A7BB3A630F13F06E6C8F0C322C2BF0F4B7BE7ADB31DC0ADCF43EA8A301540299D6C4F314D014060D982E37D66FE3F04A8A90477C1FE3FCE029BF0A0E0094056EB7AFB839E144009F162254E1AB73F4CA3B59728FDD9BF1053918F2939D93F342FE63E1BF809408EA5FF125F97F23FFBEB4A05D05A04C0C028D67D8F83FABF786D0F59808605C030E0CCEEA1ADDDBF086DDFD40D2E0640E8B675332A131340F2223DCB800D0B40A65F40716F4BF03F29DD596C77041740B751BC510549E5BF6F5F95B45B82FE3F58CBC37F7A7013C07663389FA4BE0640DA98481B700B134098CC9F1804430CC0FA59858C7981B2BFBA4C0FAE90FBEABFABB3171DB731FA3FD0790D26C36917C0EE4214C97217FCBF51F799A856C40540E67CA4A36532F4BF388D7670253FF83F7CC03BF6078A1040725425BF1FCB0140B49085273A7C0DC07208EE0787EFF23FF0A6EFEA0784FD3FC69BD19A404D07C02E9B9B17D8DDE2BF1C9BC32A15930740C2E153E7EA1DE8BFE2069BDB97212140ACD4428893ABECBFB63696C339DFD23F4BE272051827FE3F270988F04D6FE63FD1F2392AAF0EC2BF063CCCE338C40B400D961440DF3EE2BF97450D7559AD01C03C31CE98D609E83F2809291398D0D73FAEC7FB782CACD0BFC8403A26FB9206C0F6C7AE4F68B2F13F2129BA9E34E010405F1D4E58055613403DDEB91070E50040BD5EA8C279CD02C02813EB2E4E46F9BF3C47F6C950760740639E0D14B39CFA3F56A8E9AEA2AA104003AC1668FE37ED3FCE978B16023E18C0F4B864F8028CE03F70A2D376928419C0962EC02DB4200B4034775D9B89E5F23F6EB31B11ADB21740ABAA8C3AEB1C04C053B2D222AA2EE4BF92ADBCB946D90F40FC828F999CC10E4014C4505C9D5F0E40E0BF1A7D036F0D4010537BAD2714B5BFE2FF8E8A8425EBBF1EC320A0F2BFF9BFCA462B3272E40540E4791F1978FB05C08A35940CE4A915C004BC45AD1C3E14C04BC3F7DBA38F0A402D7A11769177E23FE4F1B089890400C0BE21874EC47816403450EFA1BA2A0040448168A18566D2BFB8F16A1E6CF918C0C60209BD4C910EC098C26F5F03DDD9BF7E75C721CD98F03F7ABC27761234F8BFDB20BC1DDB2110C0F54FD5A4EA631040FA19744E800618404F14E6874BB8CE3F0140A48F8B6717C06CAFB7E8DF411540D4E2D1E70D00F3BF4F273ABAB72401C05F50FC0120F6F1BF74D16C5A9A26F1BF3605D4F3668B1540D5E9D59951B5F4BFD682966EB108EC3FFEF7D07E4715F1BF085BED05D08E08C0D8D70825464ACA3F44911ABC4F3117C009E4F6CE649DE53F74F11A70DCB30340A40D4509536416C006D2478F0E27D5BF7567F3751C66EFBFC65C745F5275EC3F1C2184299B3411C09124242CA6E00E404E7C88203D16FC3F1D1DC797AD60FF3F65185E02A50F11C002035852AED10440AA40BB648C3D0BC07A8A70ED182EF5BF6D0F1DBB1A471240126EF5F47F79FFBF7E80B4D53C74F93F587C66D6335416C02C2B30D95D460EC0140836A9DC6BEFBFF5D927DF5819E33FE08C36A991E410C077CE762F3CBAF7BFAAF4B0C9B34F92BF68148E3622E621C05ACD1AE09EF6D0BFFE62EDDCF23213C0F435D34CDA0ACF3F734467ED120A07C068F934A80651FD3F5741611820BF01C0DD0A5E8385171440226EC5B0237DDCBF32DA778B1323DA3F6FE5F1E9FDA1E73FD35CA394A1160140E0A5CAEA0D0C1540382E7838CD8914C024332462CCA8FDBF1936A1A442F1F4BFFC4C5D3A493CEEBF740A56C05A6CE93F6C84FB5AD0BB18C0429D3243C69811C02479C48A75DD02409649D401EB0AF03FD2227D3FCD61E43FC8D84C00079D0A40D291A7B4DFC918C05A336DDC7278F23FA8B1F0173FFE1A4054389D950DC6004084E261CFDD33F1BF3779AB6072BA05C00427C85B02D5FCBFAEB13C1D1C36084010227CFA8EC206C07A6669EE5B050440C5534156A1AB07C0E468252C4A1500C0470ED810B758E2BFE54D01F35493FD3F3C31FDB8EA09FF3F2F0754DF689B164019BCFF05EF3901C0551022D34DB01540924BC4F92036134052D9FB0A2A8305C0B03EFBDDDC6CF0BFB2D0FD384B040640BC05836F750009C030FB9F51BFDBD8BF1E9F554AF66EF9BF2BDF93BD7192FB3FB55038DEF085E0BFC0129064A135E3BFF5258530BBBF06408FCF415726C6E03F05A8398A8802D33F641CAE5F2BCF10C04D5FC6EC3649E33F7272BFBC067BB73F5C68BF997299FABF85BCD3C7258FE23F09B632A90D4305C0971DE2BAA7200040E6FB18BB5981FFBFADE57083E1D8F8BFC53334C11186074046A27A86C3AC11C06E982338756810C0FC90585E85540540C28544D9FEE80DC0FA698DA65079D4BF1AAB8FEE000CF43FED79A66A3F34024016386BE1D31ED63F6B61A6E3F994E0BF19A7A4C1CE08F73F7D33030215E9DE3F82BFB921CB600AC05EF8B4C4F4B20440EB108B1804400940DA82CA3847A9FDBF8206FA5D34EDE1BF80FBE78E173A07C032C8EAEFEDA8E63FAA6C333F2659F13FC8D7872302420BC02927A6F887660440E3525551C44ED9BF48578B61AD0F03C0E8905244BDAD03C0BF0CCD8E95FFC23FAE004D578B29F7BF688612F4CD07FB3F0A936AF0833AEA3F9CAF42E83488ECBFB9B39401FCAFDABFC00484C440FB12C044ED48A741EACD3F267C391CB0F60DC0A83094C0168DF4BFCCA397AA317A0D409A56EEF582690640192ADA22A1CB16C0385AEA62656EC1BF4427F9FE2E0B164040F01E4C1B2700408FBA87846C4E0CC06E4C8DCD8DC7CA3F22A4E7701280CDBF85F1C7C8641709C084053C19199F02C0DE39CA4CA775E23F666CBEBEEA650EC0EEBBEC2B29B70C40C9623F202B4713400CD442B3AB2EEBBF03C3F145B9C3CE3FA658DAE8D265FDBF33537226343A12C0BFA4B6FC14E702C0B04BD469A282F23FD2CA667EBD38F0BFAA2DAE35E64CD63F82F4E2C1DDCF1640C4BA7663D5B705409D6B8AC84116F33F19BCB7C09192F1BF242E82A6CA4605C0C169018C1AB806C0C3C79B3A4E8313C0E242E56241FF13C038265FF734D6A5BFA2B62EB71CA8EE3F962254F0D01710C07D34CD5D805DCBBFDA57EC746CE5DA3F"> : tensor<3x5x40xf64>
    %cst_0 = stablehlo.constant dense<[[[-3.5634826842955114, -6.4351460280980763], [-3.0918035557648142, 0.72341777441382538], [-0.19217882682583132, -1.8461215440419003], [7.421861837149387, -7.3627362377112089], [0.2058202385135845, 1.5879187694176475]], [[0.61142182050466309, 2.6121019059178927], [-0.83808777499451992, 0.18605295305377459], [-4.5960543566730356, 5.6524093594424105], [0.10814800524464081, -2.4024231322616663], [0.65080064363309742, 2.223839602201803]], [[-8.3984132856119728, -0.35565935622558564], [-2.2963168770308089, 4.674483984738087], [1.6184151940360263, -1.0298034480292841], [4.8807343577198514, -0.53273750783189144], [4.9973366349718953, -1.4235049801961859]]]> : tensor<3x5x2xf64>
    return %cst, %cst_0 : tensor<3x5x40xf64>, tensor<3x5x2xf64>
  }
  func.func private @expected() -> (tensor<3x5x40xf64> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x50DD2297E3030B402486F8BF6AB931C08B3001FE2394DA3FED50BE22651BF4BF8E4CCB459CECD53F3E329980244C1640127B235D791E12C056234D513F092640387EDB7E23630B40B9F24C65392AE33F062A0BA189B615402FE50D5E51C001406AB49C61FA3708407C5575046AA204C05E89DD9708B702C0E87AB40A81280C4038631ACA49CE05C0819096592C7707C0BEDDA1C0FAA107C03C3DF1F25EDE02400368B523D2C510C0E0A44BC35DE6B4BF0C7367394AA01AC02B93216E72A4DF3F2B2AA20AA4F7F6BFB5C2B3D8B5420140D81A6DCE7EECF73F92902FA6CE73EDBF24A3BAD5EB60F5BF3E965C98434AF43F4A5BFB5C11250CC0B4FA7FC2EFA9EB3FF2CA73EA168916C04038195E2DA807C0F6A8BAD5C2BDEF3FCAD329AAE623054062A6AE6BDE4E0A40F46519F697DCCD3F8619494E9C4CDBBF4824635284FFF03F05C45BA9637F0E40B50D2EB0808E14C00EC8008DD39009C07858D40562E600C0E2D9B13FD9571140AA844A7F5FAADABFF2C3D736F09B19C0FE2702357B801C40BCBBE6D8D7160240BE07DFA8391DFABF1CF3AC138C0C1A4000DEE35D518B1240316BC9CE81E0FD3FF19A93F49C86E23FEF488A4A298EF5BF7AFC5A3D13D8084058AB826CD7F1FBBFFB4E2E319A9DFBBFC5A657CBBD651540A8CBC42B07C71340A8284C495CFB05C0122187585B46F7BFC88C9A29B6DF0540086CEC4F49D5F93F04E5D7B664EF114040184C614F32DD3F245B39DB0A920640DCA5CBA2885B124039D74DC17658F03FBDA21109C562E53F6A039F49DA46FE3FE8598DAB85C50C40CCC5131C1562ED3FDC110C240855E13FC00D4705FED908C0CAF87A1D1A4E02C07EC296001EBBFE3F543BFEEE6D4903407636EC7D848E09C03CFEC3B54952EF3F4081ACBD3DF00BC0E3EE3302251DEA3F7C9EC28425A3F0BFAE294F1AA3E316C0BE609F5C943205C0C2B5F9E2811FCABF728037903A221D40903A1A0D12981440BAC74F649832F13FFB683132BC46E13F4E20C368B6ECF23FBCAC737AFF7208C02A4F3605D647F63F55C2F3D05065F5BFF5282237D9B9DC3F4960A9C23671E4BFBFBD0E8686C4F13FDC2381BABFA0C8BFFB3D2A575C59FA3FA4392D92C71EFF3F1BA3299E4341D23F80758595426BF73FD8ED16E8433514400AB093DD089FF7BF96DD9FA6B727B43F686D6C10EB4120C0ECAAC57138560440F915D639BEA6E2BFCC89BF08BD5205C00E9D0B22B438DDBF94B8D80D77D7F73FC18C6266FF8DCC3F7E8A1D9673A614C01CF3CCBC51FCEB3FECAA21F73435DB3F113B4E8BEBCCEBBFCF10BE9806560440280552C1EA0BC93F0C256BC081D0FABFBBEE4BB7F7AAF33F78BAF59FB23D0A40690F7B4CF2584240B0E4A6309001084054DF7148A7F1F73F25C2CD2702CA11C0284152E77E12F63FEA949528A750633FCE1DCABF2B2909C0FE45E0F671BF054011190394997DB43FE1F7A889FA650240DFB3FDD724191240382E058F22741BC0088A33507F2005408F1A4CF55390B7BF62FF2F13D6190E40375139D0194EEBBFEC65200CF2F3F4BFD8B8E5260192FF3F92C65A234C8F0040DBD3CBBD2B2D12C00491F83C1CE31140AD8AB3A58E16FB3F4A35A23ADF671140E8E56CF6F98B0DC03047DBB8B034FCBFB2DEE934349E0D407E42E16963C3F63F8DE466AAD8C70840C3818965BA3612C026A5AC53F425F63FF6850803E8FD044072153AF1542D07C0BE8D99EA5D21F13F5EAF6924ABD5C13FA2858B0D113B1340CA3289DCD646F13F2A6F9D210B9800C000152C8E0E910340E8CD2867BA1D0C40A678445F8B9709C09FCCB0AA14B9D03FDCB69D6BC97702C04B1A6B9BA10111C01A189ED71FB3F2BF90E759B27FFBF7BFAA5C7E2F65DBF53FA690582C74C913C0C02C614CF0D213C0F48529EDB019F53F9A40045CA22B04C01D84980AB07A02401AA2A67BD74E0EC0FE30C55B88A801404E3F6D5829651040888EE974A290EA3F56260DB6040504C032036785640602C029913C12553F10C0C39C40D87ECA10402791FA264A2215C06AC0B153578AFF3F856350576907FA3F509ADCD3CBE90D40D3150A4F452AE7BF7066E062A84BDF3F888232927A04074007A1AC1EC51B21C0F44A224A7C2F0040985A4305BB86174017C38CC106E103C03BC3A2DC1C6FF5BF101B6997D88C01C0844FA2362538F5BFE7DAEE0A479801C07DD3635C684CE73F9375396795451340D46E10F0CE3F174054A8B2944F1310C0F6BC57481A4C08C0AD764C80AB2013C0E4A82C6CBA582640C44D479F9F03F1BF12E76A145B38014020A3C96473BBD7BF5AFB92AF9913E1BFC44C8A88A4C5F7BFBAE058E318C0D43FEAFF469EEE8910C0AC531D203C03FA3F2D4B8447D22EC03F60E0E60942E2E13F82D48369EEF8B73F44F3F387260DD0BF90D0E272C5DF0D401003922F7AB30CC06C93DFF03E940BC05B33A361A38DF2BF6384F0A088A807C04286A6E64D7C02C0A2BC0154F1BEE93FB80980C4A627E23F340865E66DF6FEBF98A6BBBC76A51340B6885446DD081840BF785DE379B31A40AF19E6D6AD8302C04618F5F923F6D9BF08BA7A910FA9FFBF91F44CFB251508404566C8ED31EBF1BF74DE904644BF1240CE4F5B229483EF3FE221E4736BCD0340FEEFBE96BADA0B402DCC9864E471F7BF6F8593DC26220CC0A93CBB7DDCD1C43F76C6CC15FB8611C0942B149CA13200C0550863C047D20C40267E5E3503C8CC3FE863ADCF44DAF03FB5D49DA0C3721940E296533F8D08134071147BFC652CF53FA20A4FB918C207C0FB1E2D06473406C07828CC113D6F18C0930F96657FA612404159600267A8E23F8A5108B860970340162C7FDB598914404409683ECF37ECBF6565F791919E08C02B7986AFF83F1240B7025D2AE2B2E0BFFA459F640BA6FA3F591DA16EAFB21040FE236EC667CD03C0FC66DCB94784F13F14FDEC0BBC8A1040B652433AC467C6BF4909C67A544E16C0372F8659D756FC3FA68C27C711F30440D55419E2379C0BC0A4196D28095A12C009EF230E8D15FE3F6620CE0CA7141D406FAF5209C89D09407298E4AE77F511C013B9FA5AB8BE00C0B39A8AFF8F2F923F16490BE58254E1BFCB45BA06A7B907C0B6C63D3632AE00C0F24119884D88EEBF1F6CB33EFC54EF3FF43E544F1DB8C2BF52A3A439B48C154036848A2D3FBA38C0729FEF1551AE0F4028D1BFD4655912C07AC8A583A31EF0BF54FEDFEFD4C0FA3F46CB28410155ADBFB0B29333FF46ECBF0E19FDC6ABCE08C0EE8F764DF5BE174053DDDAF404220540C0995D87653F1240E14E2D35D387F13FC550E40B724AE4BFAAAC29029089EBBF1C1EC2CCF72610401E2C03018FDADBBF752EFC92CF5F1240A83DAE5248B50D405919059A358D11C0661799410591E83F31BF0B81C6A50640A273B279BC7CBC3F50386CA7DB08F4BF2044FC09AD5401405844BE61D5CBFDBF393A6357F62005C0433DE1ECCB4113C0D8B4FCA2970CD6BF233EBE65D45901C0413696C77DB807C0BA5013587D01FB3FA9CBBD219F4600C08DCF1036375D0FC0E2E852BC2C6AAB3F771287D9D28107401235EF83CE26F5BFB2EA6DB78C3FDC3FD31E195F337B06403C8246DA080B09C06FADF133F8BFF53FFA09F885DA7EF03F0C48D73D85370E408E6484CBC16DF73F7E311A945F69DC3FF14A7BB3A630F13F06E6C8F0C322C2BF0F4B7BE7ADB31DC0ADCF43EA8A301540299D6C4F314D014060D982E37D66FE3F04A8A90477C1FE3FCE029BF0A0E0094056EB7AFB839E144009F162254E1AB73F4CA3B59728FDD9BF1053918F2939D93F342FE63E1BF809408EA5FF125F97F23FFBEB4A05D05A04C0C028D67D8F83FABF786D0F59808605C030E0CCEEA1ADDDBF086DDFD40D2E0640E8B675332A131340F2223DCB800D0B40A65F40716F4BF03F29DD596C77041740B751BC510549E5BF6F5F95B45B82FE3F58CBC37F7A7013C07663389FA4BE0640DA98481B700B134098CC9F1804430CC0FA59858C7981B2BFBA4C0FAE90FBEABFABB3171DB731FA3FD0790D26C36917C0EE4214C97217FCBF51F799A856C40540E67CA4A36532F4BF01479547BA8B01407CC03BF6078A1040725425BF1FCB0140B49085273A7C0DC07208EE0787EFF23FF0A6EFEA0784FD3FC69BD19A404D07C02E9B9B17D8DDE2BF1C9BC32A15930740C2E153E7EA1DE8BFE2069BDB97212140ACD4428893ABECBFB63696C339DFD23F4BE272051827FE3F270988F04D6FE63FD1F2392AAF0EC2BF063CCCE338C40B400D961440DF3EE2BF97450D7559AD01C03C31CE98D609E83F2809291398D0D73FAEC7FB782CACD0BFC8403A26FB9206C0F6C7AE4F68B2F13F2129BA9E34E010405F1D4E58055613403DDEB91070E50040BD5EA8C279CD02C02813EB2E4E46F9BF3C47F6C950760740639E0D14B39CFA3F56A8E9AEA2AA104003AC1668FE37ED3FCE978B16023E18C0F4B864F8028CE03F70A2D376928419C0962EC02DB4200B4034775D9B89E5F23F6EB31B11ADB21740ABAA8C3AEB1C04C07F9663DA5824FEBF92ADBCB946D90F40FC828F999CC10E4014C4505C9D5F0E40E0BF1A7D036F0D4010537BAD2714B5BFE2FF8E8A8425EBBF1EC320A0F2BFF9BFCA462B3272E40540E4791F1978FB05C08A35940CE4A915C004BC45AD1C3E14C04BC3F7DBA38F0A402D7A11769177E23FE4F1B089890400C0BE21874EC47816403450EFA1BA2A0040448168A18566D2BFB8F16A1E6CF918C0C60209BD4C910EC098C26F5F03DDD9BF7E75C721CD98F03F7ABC27761234F8BFDB20BC1DDB2110C0F54FD5A4EA631040FA19744E800618404F14E6874BB8CE3F0140A48F8B6717C06CAFB7E8DF411540D4E2D1E70D00F3BF4F273ABAB72401C05F50FC0120F6F1BF74D16C5A9A26F1BF3605D4F3668B1540D5E9D59951B5F4BFD682966EB108EC3FFEF7D07E4715F1BF085BED05D08E08C0D8D70825464ACA3F44911ABC4F3117C0C33ADC717F001DC074F11A70DCB30340A40D4509536416C006D2478F0E27D5BF7567F3751C66EFBFC65C745F5275EC3F1C2184299B3411C09124242CA6E00E404E7C88203D16FC3F1D1DC797AD60FF3F65185E02A50F11C002035852AED10440AA40BB648C3D0BC07A8A70ED182EF5BF6D0F1DBB1A471240126EF5F47F79FFBF7E80B4D53C74F93F587C66D6335416C02C2B30D95D460EC0140836A9DC6BEFBFF5D927DF5819E33FE08C36A991E410C077CE762F3CBAF7BFAAF4B0C9B34F92BF68148E3622E621C05ACD1AE09EF6D0BFFE62EDDCF23213C0F435D34CDA0ACF3F734467ED120A07C068F934A80651FD3F5741611820BF01C0DD0A5E8385171440226EC5B0237DDCBF32DA778B1323DA3F6FE5F1E9FDA1E73FD35CA394A1160140E0A5CAEA0D0C1540382E7838CD8914C024332462CCA8FDBF1936A1A442F1F4BFB112E30F2C32F93F740A56C05A6CE93F6C84FB5AD0BB18C0429D3243C69811C02479C48A75DD02409649D401EB0AF03FD2227D3FCD61E43FC8D84C00079D0A40D291A7B4DFC918C05A336DDC7278F23FA8B1F0173FFE1A4054389D950DC6004084E261CFDD33F1BF3779AB6072BA05C00427C85B02D5FCBFAEB13C1D1C36084010227CFA8EC206C07A6669EE5B050440C5534156A1AB07C0E468252C4A1500C0470ED810B758E2BFE54D01F35493FD3F3C31FDB8EA09FF3F2F0754DF689B164019BCFF05EF3901C0551022D34DB01540924BC4F92036134052D9FB0A2A8305C0B03EFBDDDC6CF0BFB2D0FD384B040640BC05836F750009C030FB9F51BFDBD8BF1E9F554AF66EF9BF2BDF93BD7192FB3FB55038DEF085E0BFC0129064A135E3BFF5258530BBBF06408FCF415726C6E03F05A8398A8802D33F641CAE5F2BCF10C0238BC3F5BF12F9BF7272BFBC067BB73F5C68BF997299FABF85BCD3C7258FE23F09B632A90D4305C0971DE2BAA7200040E6FB18BB5981FFBFADE57083E1D8F8BFC53334C11186074046A27A86C3AC11C06E982338756810C0FC90585E85540540C28544D9FEE80DC0FA698DA65079D4BF1AAB8FEE000CF43FED79A66A3F34024016386BE1D31ED63F6B61A6E3F994E0BF19A7A4C1CE08F73F7D33030215E9DE3F82BFB921CB600AC05EF8B4C4F4B20440EB108B1804400940DA82CA3847A9FDBF8206FA5D34EDE1BF80FBE78E173A07C032C8EAEFEDA8E63FAA6C333F2659F13FC8D7872302420BC02927A6F887660440E3525551C44ED9BF48578B61AD0F03C0E8905244BDAD03C0BF0CCD8E95FFC23FAE004D578B29F7BF688612F4CD07FB3F0A936AF0833AEA3F9CAF42E83488ECBFB9B39401FCAFDABFC00484C440FB12C07FD46A7AD999FABF267C391CB0F60DC0A83094C0168DF4BFCCA397AA317A0D409A56EEF582690640192ADA22A1CB16C0385AEA62656EC1BF4427F9FE2E0B164040F01E4C1B2700408FBA87846C4E0CC06E4C8DCD8DC7CA3F22A4E7701280CDBF85F1C7C8641709C084053C19199F02C0DE39CA4CA775E23F666CBEBEEA650EC0EEBBEC2B29B70C40C9623F202B4713400CD442B3AB2EEBBF03C3F145B9C3CE3FA658DAE8D265FDBF33537226343A12C0BFA4B6FC14E702C0B04BD469A282F23FD2CA667EBD38F0BFAA2DAE35E64CD63F82F4E2C1DDCF1640C4BA7663D5B705409D6B8AC84116F33F19BCB7C09192F1BF242E82A6CA4605C0C169018C1AB806C0C3C79B3A4E8313C0E242E56241FF13C038265FF734D6A5BFA2B62EB71CA8EE3F962254F0D01710C07D34CD5D805DCBBFDA57EC746CE5DA3F"> : tensor<3x5x40xf64>
    return %cst : tensor<3x5x40xf64>
  }
}