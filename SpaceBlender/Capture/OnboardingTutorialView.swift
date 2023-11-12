/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The guidance view that shows the video tutorial or the point cloud on the review screen.
*/


// reference: third-party object capture tool: https://developer.apple.com/augmented-reality/object-capture/

import Foundation
import RealityKit
import SwiftUI



/// The view that either shows the point cloud or plays the guidance tutorials on the review screens.
/// This depends on `currentState` in `onboardingStateMachine`.
@available(iOS 17.0, *)
struct OnboardingTutorialView: View {
    @EnvironmentObject var appModel: AppDataModel
    var session: ObjectCaptureSession
    @ObservedObject var onboardingStateMachine: OnboardingStateMachine

    var body: some View {
        VStack {
            ZStack {
                if shouldShowTutorialInReview, let url = tutorialUrl {
                    TutorialVideoView(url: url, isInReviewSheet: true)
                        .padding(30)
                } else {
                    ObjectCapturePointCloudView(session: session)
                        .padding(30)
                }

                VStack {
                    Spacer()
                    HStack {
                        ForEach(AppDataModel.Orbit.allCases) { orbit in
                            if let orbitImageName = getOrbitImageName(orbit: orbit) {
                                Text(Image(systemName: orbitImageName))
                                    .font(.system(size: 28))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.bottom)
                }
            }
            .frame(maxHeight: .infinity)

            VStack {
                Text(title)
                    .font(.largeTitle)
                    .lineLimit(3)
                    .minimumScaleFactor(0.5)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                    .frame(maxWidth: .infinity)

                Text(detailText)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                Spacer()
            }
            .frame(maxHeight: .infinity)
            .padding(.leading, UIDevice.current.userInterfaceIdiom == .pad ? 50 : 30)
            .padding(.trailing, UIDevice.current.userInterfaceIdiom == .pad ? 50 : 30)

        }
    }

    private var shouldShowTutorialInReview: Bool {
        switch onboardingStateMachine.currentState {
            case .flipObject, .flipObjectASecondTime, .captureFromLowerAngle, .captureFromHigherAngle:
                return true
            default:
                return false
        }
    }
    
    

    private let onboardingStateToTutorialNameMapOnIphone: [OnboardingState: String] = [
        .flipObject: "ScanPasses-iPhone-FixedHeight-2",
        .flipObjectASecondTime: "ScanPasses-iPhone-FixedHeight-3",
        .captureFromLowerAngle: "ScanPasses-iPhone-FixedHeight-unflippable-low",
        .captureFromHigherAngle: "ScanPasses-iPhone-FixedHeight-unflippable-high"
    ]

    private let onboardingStateToTutorialNameMapOnIpad: [OnboardingState: String] = [
        .flipObject: "ScanPasses-iPad-FixedHeight-2",
        .flipObjectASecondTime: "ScanPasses-iPad-FixedHeight-3",
        .captureFromLowerAngle: "ScanPasses-iPad-FixedHeight-unflippable-low",
        .captureFromHigherAngle: "ScanPasses-iPad-FixedHeight-unflippable-high"
    ]

    private var tutorialUrl: URL? {
        let videoName: String
        if UIDevice.current.userInterfaceIdiom == .pad {
            videoName = onboardingStateToTutorialNameMapOnIpad[onboardingStateMachine.currentState] ?? "ScanPasses-iPad-FixedHeight-1"
        } else {
            videoName = onboardingStateToTutorialNameMapOnIphone[onboardingStateMachine.currentState] ?? "ScanPasses-iPhone-FixedHeight-1"
        }
        return Bundle.main.url(forResource: videoName, withExtension: "mp4")
    }

    private func getOrbitImageName(orbit: AppDataModel.Orbit) -> String? {
        guard let session = appModel.objectCaptureSession else { return nil }
        let orbitCompleted = session.userCompletedScanPass
        let orbitCompleteImage = orbit <= appModel.orbit ? orbit.imageSelected : orbit.image
        let orbitNotCompleteImage = orbit < appModel.orbit ? orbit.imageSelected : orbit.image
        return orbitCompleted ? orbitCompleteImage : orbitNotCompleteImage
    }

    private let onboardingStateToTitleMap: [OnboardingState: String] = [
        .tooFewImages: LocalizedString.tooFewImagesTitle,
        .firstSegmentNeedsWork: LocalizedString.firstSegmentNeedsWorkTitle,
        .firstSegmentComplete: LocalizedString.firstSegmentCompleteTitle,
        .secondSegmentNeedsWork: LocalizedString.secondSegmentNeedsWorkTitle,
        .secondSegmentComplete: LocalizedString.secondSegmentCompleteTitle,
        .thirdSegmentNeedsWork: LocalizedString.thirdSegmentNeedsWorkTitle,
        .thirdSegmentComplete: LocalizedString.thirdSegmentCompleteTitle,
        .flipObject: LocalizedString.flipObjectTitle,
        .flipObjectASecondTime: LocalizedString.flipObjectASecondTimeTitle,
        .flippingObjectNotRecommended: LocalizedString.flippingObjectNotRecommendedTitle,
        .captureFromLowerAngle: LocalizedString.captureFromLowerAngleTitle,
        .captureFromHigherAngle: LocalizedString.captureFromHigherAngleTitle
    ]

    private var title: String {
        onboardingStateToTitleMap[onboardingStateMachine.currentState] ?? ""
    }

    private let onboardingStateTodetailTextMap: [OnboardingState: String] = [
        .tooFewImages: String(format: LocalizedString.tooFewImagesDetailText, AppDataModel.minNumImages),
        .firstSegmentNeedsWork: LocalizedString.firstSegmentNeedsWorkDetailText,
        .firstSegmentComplete: LocalizedString.firstSegmentCompleteDetailText,
        .secondSegmentNeedsWork: LocalizedString.secondSegmentNeedsWorkDetailText,
        .secondSegmentComplete: LocalizedString.secondSegmentCompleteDetailText,
        .thirdSegmentNeedsWork: LocalizedString.thirdSegmentNeedsWorkDetailText,
        .thirdSegmentComplete: LocalizedString.thirdSegmentCompleteDetailText,
        .flipObject: LocalizedString.flipObjectDetailText,
        .flipObjectASecondTime: LocalizedString.flipObjectASecondTimeDetailText,
        .flippingObjectNotRecommended: LocalizedString.flippingObjectNotRecommendedDetailText,
        .captureFromLowerAngle: LocalizedString.captureFromLowerAngleDetailText,
        .captureFromHigherAngle: LocalizedString.captureFromHigherAngleDetailText
    ]

    private var detailText: String {
        onboardingStateTodetailTextMap[onboardingStateMachine.currentState] ?? ""
    }
    
    struct LocalizedString {
        static let tooFewImagesTitle = NSLocalizedString(
            "Keep moving around your object. (Review, Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Keep moving around your object.",
            comment: "Feedback title for when user has less than the minimum images required."
        )

        static let tooFewImagesDetailText = NSLocalizedString(
            "You need at least \(AppDataModel.minNumImages) images of your object to create a model. (Review, Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "You need at least %d images of your object to create a model.",
            comment: "Feedback for when user has less than the minimum images required."
        )

        static let firstSegmentNeedsWorkTitle = NSLocalizedString(
            "Keep going to complete the first segment. (Review, Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Keep going to complete the first segment.",
            comment: "Feedback title for when user still has work to do to complete the first segment."
        )

        static let firstSegmentNeedsWorkDetailText = NSLocalizedString(
            """
            For best quality, capture three segments.
            Tap Skip if you can't make it all the way around, but your final model may have missing areas. (Review, Object Capture, 1st Segment)
            """,
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: """
                For best quality, capture three segments.
                Tap Skip if you can't make it all the way around, but your final model may have missing areas.
                """,
            comment: "Feedback for when user still has work to do to complete the first segment."
        )

        static let firstSegmentCompleteTitle = NSLocalizedString(
            "First segment complete. (Review, Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "First segment complete.",
            comment: "Feedback title for when user has finished capturing first segment."
        )

        static let firstSegmentCompleteDetailText = NSLocalizedString(
            "For best quality, capture three segments. (Review, Object Capture, 1st Segment)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "For best quality, caputure three segments.",
            comment: "Feedback for when user has finished capturing first segment."
        )

        static let flipObjectTitle = NSLocalizedString(
            "Flip object on its side and capture again. (Review, Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Flip object on its side and capture again.",
            comment: "Feedback title for when user should flip the object and capture again."
        )

        static let flipObjectDetailText = NSLocalizedString(
            "Make sure that areas you captured previously can still be seen. (Review, Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Make sure that areas you captured previously can still be seen. Avoid flipping your object if it changes the shape.",
            comment: "Feedback for when user should flip the object and capture again"
        )

        static let flippingObjectNotRecommendedTitle = NSLocalizedString(
            "Flipping this object is not recommended. (Review, Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Flipping this object is not recommended.",
            comment: "Feedback title that this object is likely to fail if flipped."
        )

        static let flippingObjectNotRecommendedDetailText = NSLocalizedString(
            """
            Your object may have single color surfaces or be too reflective to add more segments.
            Tap Continue to capture more detail without flipping, or Flip Object Anyway. (Review, Object Capture)
            """,
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: """
                Your object may have single color surfaces or be too reflective to add more segments.
                Tap Continue to capture more detail without flipping, or Flip Object Anyway.
                """,
            comment: "Feedback that this object is likely to fail if flipped."
        )

        static let captureFromLowerAngleTitle = NSLocalizedString(
            "Capture your object again from a lower angle. (Review, Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Capture your object again from a lower angle.",
            comment: "Feedback title for when user should capture again from a lower angle given flipping isn't recommended."
        )

        static let captureFromLowerAngleDetailText = NSLocalizedString(
            "Move down to be level with the base of your object and capture again. (Review, Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Move down to be level with the base of your object and capture again.",
            comment: "Feedback for when user should capture again from a lower angle given flipping isn't recommended."
        )

        static let secondSegmentNeedsWorkTitle = NSLocalizedString(
            "Keep going to complete the second segment. (Review, Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Keep going to complete the second segment.",
            comment: "Feedback title for when user has not finished capturing second segment."
        )

        static let secondSegmentNeedsWorkDetailText = NSLocalizedString(
            """
            For best quality, capture three segments.
            Tap Skip if you can't make it all the way around but your final model may have missing areas. (Review, Object Capture, 2nd Segment)
            """,
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: """
                For best quality, capture three segments.
                Tap Skip if you can't make it all the way around but your final model may have missing areas.
                """,
            comment: "Feedback title for when user has not finished capturing second segment."
        )

        static let secondSegmentCompleteTitle = NSLocalizedString(
            "Second segment complete. (Review, Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Second segment complete.",
            comment: "Feedback title for when user has finished capturing second segment."
        )

        static let secondSegmentCompleteDetailText = NSLocalizedString(
            "For best quality, capture three segments. (Review, Object Capture, 2nd segment)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "For best quality, capture three segments.",
            comment: "Feedback title for when user has finished capturing second segment."
        )

        static let flipObjectASecondTimeTitle = NSLocalizedString(
            "Flip object on the opposite side and capture again. (Review, Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Flip object on the opposite side and capture again",
            comment: "Feedback title for when user has not flipped object on the opposite side."
        )

        static let flipObjectASecondTimeDetailText = NSLocalizedString(
            "Make sure that areas you captured previously can still be seen. (Review, Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Make sure that areas you captured previously can still be seen. Avoid flipping your object if it changes the shape.",
            comment: "Feedback for when user has not flipped object on the opposite side."
        )

        static let captureFromHigherAngleTitle = NSLocalizedString(
            "Capture your object again from a higher angle. (Review, Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Capture your object again from a higher angle.",
            comment: "Feedback title for when user should capture again from a higher angle given flipping isn't recommended."
        )

        static let captureFromHigherAngleDetailText = NSLocalizedString(
            "Move above your object and make sure that areas you captured previously can still be seen. (Review, Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Move above your object and make sure that areas you captured previously can still be seen.",
            comment: "Feedback for when user should capture again from above given flipping isn't recommended."
        )

        static let thirdSegmentNeedsWorkTitle = NSLocalizedString(
            "Keep going to complete the final segment. (Review, Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Keep going to complete the final segment.",
            comment: "Feedback title for when user still has work to do to complete the final segment."
        )

        static let thirdSegmentNeedsWorkDetailText = NSLocalizedString(
            "For best quality, capture three segments. When you're done, tap Finish to complete your object. (Review, Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "For best quality, capture three segments. When you're done, tap Finish to complete your object.",
            comment: "Feedback for when user still has work to do to complete the final segment."
        )

        static let thirdSegmentCompleteTitle = NSLocalizedString(
            "All segments complete. (Review, Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "All segments complete.",
            comment: "Feedback title for when user has finished capturing final segment."
        )

        static let thirdSegmentCompleteDetailText = NSLocalizedString(
            "Tap Finish to process your object. (Review, Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Tap Finish to process your object.",
            comment: "Feedback for when user has finished capturing final segment."
        )
    }

}

