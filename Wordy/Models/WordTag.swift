//
//  WordTag.swift
//
//  Created by Joey Zhang on 2023/2/21.
//

import Foundation

public enum WordTag: CaseIterable, Decodable {
    case zhongKao
    case gaoKao
    case cet4
    case cet6
    case ky
    case toefl
    case ielts
    case gre
    case collins(stars: Int)
    case oxford

    public init?(rawValue: String) {
        switch rawValue {
        case "zk":       self = .zhongKao
        case "gk":       self = .gaoKao
        case "cet4":     self = .cet4
        case "cet6":     self = .cet6
        case "ky":       self = .ky
        case "toefl":    self = .toefl
        case "ielts":    self = .ielts
        case "gre":      self = .gre
        default:
            return nil
        }
    }

    public var code: String {
        switch self {
        case .zhongKao:
            return "zk"
        case .gaoKao:
            return "gk"
        case .cet4:
            return "cet4"
        case .cet6:
            return "cet6"
        case .ky:
            return "ky"
        case .toefl:
            return "toefl"
        case .ielts:
            return "ielts"
        case .collins:
            return "collins"
        case .oxford:
            return "oxford"
        case .gre:
            return "gre"
        }
    }

    public var displayName: String {
        switch self {
        case .zhongKao:
            return "中考词汇"
        case .gaoKao:
            return "高考词汇"
        case .cet4:
            return "4级词汇"
        case .cet6:
            return "6级词汇"
        case .ky:
            return "考研词汇"
        case .toefl:
            return "托福词汇"
        case .ielts:
            return "雅思词汇"
        case .collins(let star):
            return "柯林斯\(star)星词汇"
        case .oxford:
            return "牛津3000词汇"
        case .gre:
            return "GRE词汇"
        }
    }

//    public var description: String {
//        switch self {
//        case .zhongKao:
//            return "初中学业水平考试(The Academic Test for the Junior High School Students)，简称中考，是检验初中在校生是否达到初中学业水平的考试。"
//        case .gaoKao:
//            return "普通高等学校招生全国统一考试(Nationwide Unified Examination for Admissions to General Universities and Colleges)，简称：高考。"
//        case .cet4:
//            return "大学英语四级考试，即CET-4，College English Test Band 4的缩写，是由国家教育部高等教育司主持的全国性英语考试。"
//        case .cet6:
//            return "大学英语六级考试(又称CET-6，全称为“College English Test-6”)，是由国家教育部高等教育司主持的全国性英语考试。"
//        case .ky:
//            return "全国硕士研究生统一招生考试(Unified National Graduate Entrance Examination)，简称：考研、统考。"
//        case .toefl:
//            return "检定非英语为母语者的英语能力考试(英语：Test of English as a Foreign Language)，简称：托福，是由美国教育测验服务社举办的英语能力测验。"
//        case .ielts:
//            return "雅思，IELTS，全称为国际英语测试系统(International English Language Testing System)，是著名的国际性英语标准化水平测试之一。"
//        case .collins:
//            return "柯林斯从语料库中将单词在日常生活中的使用频率统计出来，按照频率的高低将单词分级，五星的就是日常生活中最常用的，依次类推。"
//        case .oxford:
//            return "牛津字典核心3000词汇(The Oxford 3000 wordlist)是参照BNC语料库的词频统计， 选出了最常用的3000个词汇作为“定义词汇”的。"
//        case .gre:
//            return "GRE，全称Graduate Record Examination，中文名称为美国研究生入学考试，适用于申请世界范围内的理工科、人文社科、商科、法学等多个专业的硕士、博士以及MBA等教育项目，由美国教育考试服务中心(Educational Testing Service，简称ETS)主办。"
//        }
//    }

    public static var allCases: [WordTag] {
        [.zhongKao, .gaoKao, .cet4, .cet6, .ky, .toefl, .ielts, .gre, .collins(stars: 1), .collins(stars: 2), .collins(stars: 3), .collins(stars: 4), .collins(stars: 5), .oxford]
    }
}

extension WordTag: Identifiable {
    public var id: String {
        return displayName
    }
}
