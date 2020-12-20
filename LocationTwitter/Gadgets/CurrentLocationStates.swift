//
//  CurrentLocationStates.swift
//  BeenThere
//
//  Created by 한석희 on 12/4/20.
//

import Foundation

// msgLabelText
// addressLabelText
// blogLabelisHidden
// getLocationButtonTitle

//
enum CurrentLocationState {
    //
    case beforePress, updatingLoc, completeLoc, unknownTill6, unknownToFail, locSerDeniedDetected
    //
    var msgLabelText : String {
        switch self {
            case .beforePress:
                return "( 나의 위치를 찾아보세요 )"
            case .updatingLoc:
                return "위치를 더 정확하게 감지하는 중..."
            case .completeLoc:
                return "위치 검색 완료!! ( 더 정확한 위치에는 GPS, 데이터가 도움이 됩니다 🙂)"
            case .unknownTill6:
                return "위치 검색 중..."
            case .unknownToFail:
                return "( 위치 검색 실패)"
            case .locSerDeniedDetected:
                return "(위치 서비스가 허용되어 있지 않습니다.)"
        }
    }
    //
    var addressLabelText : String {
        switch self {
            case .beforePress:
                return "아직 검색된 주소가 없습니다."
            case .updatingLoc:
                return "아직 위치가 확정되지 않았습니다"
            case .completeLoc:
                return "아직 위치가 확정되지 않았습니다" //🍎 지오 코딩된 실제 주소를 넣기
            case .unknownTill6:
                return "아직 위치가 확정되지 않았습니다"
            case .unknownToFail:
                return "아직 검색된 주소가 없습니다."
            case .locSerDeniedDetected:
                return "아직 검색된 주소가 없습니다."
        }
    }
    //
    var blogButtonIsHidden : Bool {
        return true
    }
    //
    var getLocationButtonTitle : String {
            switch self {
                case .beforePress:
                    return "내 위치 가져오기"
                case .updatingLoc:
                    return "위치 업데이트 중지"
                case .completeLoc:
                    return "내 위치 다시 가져오기"
                case .unknownTill6:
                    return "" //🍎  isHidden  = true
                case .unknownToFail:
                    return "위치 가져오기 다시 시도"
                case .locSerDeniedDetected:
                    return "위치 가져오기 다시 시도"
            }
    }
    //
}
