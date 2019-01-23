//
//  RasmussenInvariant.swift
//  Sample
//
//  Created by Taketo Sano on 2018/12/06.
//

import Foundation

internal extension Link {
    static func loadRasmussenInvariant(_ name: String) -> Int? {
        if _data.isEmpty {
            _data = Data.loadJSON(_jsonString)!
        }
        
        return _data[name]
    }
}

private typealias Data = [String: Int]
private var _data: Data = [:]
private let _jsonString = """
{
"3_1":-2, "4_1":0, "5_1":-4, "5_2":-2, "6_1":0, "6_2":-2, "6_3":0, "7_1":-6, "7_2":-2, "7_3":4, "7_4":2, "7_5":-4, "7_6":-2, "7_7":0, "8_1":0, "8_2":-4, "8_3":0, "8_4":-2, "8_5":4, "8_6":-2, "8_7":2, "8_8":0, "8_9":0, "8_10":2, "8_11":-2, "8_12":0, "8_13":0, "8_14":-2, "8_15":-4, "8_16":-2, "8_17":0, "8_18":0, "8_19":6, "8_20":0, "8_21":-2, "9_1":-8, "9_2":-2, "9_3":6, "9_4":-4, "9_5":2, "9_6":-6, "9_7":-4, "9_8":-2, "9_9":-6, "9_10":4, "9_11":4, "9_12":-2, "9_13":4, "9_14":0, "9_15":2, "9_16":6, "9_17":-2, "9_18":-4, "9_19":0, "9_20":-4, "9_21":2, "9_22":2, "9_23":-4, "9_24":0, "9_25":-2, "9_26":2, "9_27":0, "9_28":-2, "9_29":-2, "9_30":0, "9_31":-2, "9_32":2, "9_33":0, "9_34":0, "9_35":-2, "9_36":4, "9_37":0, "9_38":-4, "9_39":2, "9_40":-2, "9_41":0, "9_42":0, "9_43":4, "9_44":0, "9_45":-2, "9_46":0, "9_47":2, "9_48":2, "9_49":4, "10_1":0, "10_2":-6, "10_3":0, "10_4":-2, "10_5":4, "10_6":-4, "10_7":-2, "10_8":-4, "10_9":2, "10_10":0, "10_11":-2, "10_12":2, "10_13":0, "10_14":-4, "10_15":2, "10_16":2, "10_17":0, "10_18":-2, "10_19":-2, "10_20":-2, "10_21":-4, "10_22":0, "10_23":2, "10_24":-2, "10_25":-4, "10_26":0, "10_27":-2, "10_28":0, "10_29":-2, "10_30":-2, "10_31":0, "10_32":0, "10_33":0, "10_34":0, "10_35":0, "10_36":-2, "10_37":0, "10_38":-2, "10_39":-4, "10_40":2, "10_41":-2, "10_42":0, "10_43":0, "10_44":-2, "10_45":0, "10_46":6, "10_47":4, "10_48":0, "10_49":-6, "10_50":4, "10_51":2, "10_52":2, "10_53":-4, "10_54":2, "10_55":-4, "10_56":4, "10_57":2, "10_58":0, "10_59":2, "10_60":0, "10_61":4, "10_62":4, "10_63":-4, "10_64":2, "10_65":2, "10_66":-6, "10_67":-2, "10_68":0, "10_69":2, "10_70":2, "10_71":0, "10_72":4, "10_73":-2, "10_74":-2, "10_75":0, "10_76":4, "10_77":2, "10_78":-4, "10_79":0, "10_80":-6, "10_81":0, "10_82":-2, "10_83":2, "10_84":2, "10_85":-4, "10_86":0, "10_87":0, "10_88":0, "10_89":-2, "10_90":0, "10_91":0, "10_92":4, "10_93":-2, "10_94":2, "10_95":2, "10_96":0, "10_97":2, "10_98":-4, "10_99":0, "10_100":-4, "10_101":4, "10_102":0, "10_103":-2, "10_104":0, "10_105":2, "10_106":2, "10_107":0, "10_108":2, "10_109":0, "10_110":-2, "10_111":4, "10_112":-2, "10_113":2, "10_114":0, "10_115":0, "10_116":-2, "10_117":2, "10_118":0, "10_119":0, "10_120":-4, "10_121":-2, "10_122":0, "10_123":0, "10_124":8, "10_125":2, "10_126":-2, "10_127":-4, "10_128":6, "10_129":0, "10_130":0, "10_131":-2, "10_132":-2, "10_133":-2, "10_134":6, "10_135":0, "10_136":0, "10_137":0, "10_138":2, "10_139":8, "10_140":0, "10_141":0, "10_142":6, "10_143":-2, "10_144":-2, "10_145":-4, "10_146":0, "10_147":2, "10_148":-2, "10_149":-4, "10_150":4, "10_151":2, "10_152":-8, "10_153":0, "10_154":6, "10_155":0, "10_156":-2, "10_157":4, "10_158":0, "10_159":-2, "10_160":4, "10_161":-6, "10_162":-2, "10_163":2, "10_164":0, "10_165":2
}
"""
