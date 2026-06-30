import SwiftUI
import AppKit
import CoreGraphics
import ApplicationServices

// MARK: - Overlay window (borderless, key-capable, full-screen)

/// Borderless window that can still become key so the card's buttons and the
/// interactive keybind step receive events. Hosted full-screen by AppDelegate.
final class OverlayWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

// MARK: - Onboarding (Raycast-style overlay)

struct OnboardingView: View {
    @EnvironmentObject var settings: AppSettings
    var onFinish: () -> Void

    @State private var step = 0
    @State private var appeared = false
    @State private var exiting = false
    @State private var screenOK = false
    @State private var axOK = false

    private let lastStep = 3
    private let poll = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            AuroraBackground().ignoresSafeArea()

            card
                .scaleEffect(exiting ? 1.03 : (appeared ? 1 : 0.96))
                .opacity(appeared ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(exiting ? 0 : 1) // whole overlay fades out on finish
        .preferredColorScheme(.dark)
        .onAppear {
            refreshPermissions()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.82)) { appeared = true }
        }
        .onReceive(poll) { _ in refreshPermissions() }
        .onExitCommand { finish() } // Esc skips
    }

    private var card: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(30)
                .id(step)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)))
            footer
        }
        .frame(width: 560, height: 620)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Gruv.bg0.opacity(0.82))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1))
        .shadow(color: .black.opacity(0.55), radius: 40, y: 18)
    }

    @ViewBuilder private var content: some View {
        switch step {
        case 0: welcome
        case 1: permissions
        case 2: TryItStep()
        default: done
        }
    }

    // MARK: Steps

    private var welcome: some View {
        VStack(spacing: 18) {
            Spacer()
            SnipMark()
            Text("Nab").font(.mono(28, weight: .bold)).foregroundColor(Gruv.fg0)
            Text("Nab it. It's already on your clipboard.")
                .font(.system(size: 14)).foregroundColor(Gruv.orange)
            Text("A menubar capture tool that drops a clean link onto your clipboard the instant you nab. Two quick steps: grant a couple of permissions, learn two gestures. Let's go.")
                .font(.system(size: 13)).foregroundColor(Gruv.fg3)
                .multilineTextAlignment(.center).frame(maxWidth: 400)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var permissions: some View {
        VStack(alignment: .leading, spacing: 14) {
            stepTitle("Permissions", "Two macOS permissions. Grant them here — the status updates live.")
            permissionCard(
                icon: "camera.viewfinder", tint: Gruv.aqua, title: "Screen Recording",
                desc: "To capture a screen region.", granted: screenOK) { requestScreen() }
            permissionCard(
                icon: "hand.tap.fill", tint: Gruv.yellow, title: "Accessibility",
                desc: "For the global double-⌘ / double-⌃ gestures.", granted: axOK) { requestAX() }
            Text(screenOK && axOK
                 ? "Both granted — you're ready for the gestures."
                 : "You can grant later too; capture still works from the menubar.")
                .font(.system(size: 11)).foregroundColor(screenOK && axOK ? Gruv.green : Gruv.gray)
                .animation(.easeInOut, value: screenOK && axOK)
            Spacer()
        }
    }

    private var done: some View {
        ZStack {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "checkmark.circle.fill").font(.system(size: 56)).foregroundColor(Gruv.green)
                    .scaleEffect(appeared ? 1 : 0.3)
                Text("You're all set").font(.mono(22, weight: .bold)).foregroundColor(Gruv.fg0)
                VStack(alignment: .leading, spacing: 8) {
                    tip("Tap ⌘ twice", "capture a region → link copied")
                    tip("Tap ⌃ twice", "share selected text → link copied")
                    tip("⇧ + ⌃⌃", "share it raw — skip the styled window")
                    tip("Menubar ✂", "actions + Settings anytime")
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 12).fill(Gruv.bg1.opacity(0.7)))
                Spacer()
            }
            ConfettiBurst().id("done-confetti")
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Pieces

    private func stepTitle(_ title: String, _ subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.mono(20, weight: .bold)).foregroundColor(Gruv.fg0)
            Text(subtitle).font(.system(size: 13)).foregroundColor(Gruv.fg3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func permissionCard(icon: String, tint: Color, title: String, desc: String,
                                granted: Bool, action: @escaping () -> Void) -> some View {
        Card {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8, style: .continuous).fill(granted ? Gruv.green : tint)
                    .frame(width: 30, height: 30)
                    .overlay(Image(systemName: granted ? "checkmark" : icon)
                        .font(.system(size: 14, weight: .semibold)).foregroundColor(Gruv.bg0h))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 13, weight: .semibold)).foregroundColor(Gruv.fg1)
                    Text(granted ? "Granted" : desc)
                        .font(.system(size: 11)).foregroundColor(granted ? Gruv.green : Gruv.gray)
                }
                Spacer()
                if granted {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(Gruv.green).font(.system(size: 18))
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Button(action: action) {
                        Text("Grant").font(.system(size: 12, weight: .medium)).foregroundColor(Gruv.orange)
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(RoundedRectangle(cornerRadius: 7).fill(Gruv.orange.opacity(0.12)))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(granted ? Gruv.green.opacity(0.5) : .clear, lineWidth: 1.5))
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: granted)
    }

    private func tip(_ key: String, _ desc: String) -> some View {
        HStack(spacing: 10) {
            Text(key).font(.mono(11, weight: .semibold)).foregroundColor(Gruv.fg0)
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(RoundedRectangle(cornerRadius: 6).fill(Gruv.bg2))
            Text(desc).font(.system(size: 12)).foregroundColor(Gruv.fg3)
            Spacer()
        }
    }

    private var footer: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0...lastStep, id: \.self) { i in
                    Circle().fill(i == step ? Gruv.orange : Gruv.bg3)
                        .frame(width: i == step ? 8 : 7, height: i == step ? 8 : 7)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: step)
                }
            }
            Spacer()
            if step == 0 {
                Button("Skip") { finish() }
                    .buttonStyle(.plain).foregroundColor(Gruv.gray).font(.system(size: 13))
                    .padding(.horizontal, 12)
            } else {
                Button("Back") { withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { step -= 1 } }
                    .buttonStyle(.plain).foregroundColor(Gruv.fg3).font(.system(size: 13))
                    .padding(.horizontal, 12)
            }
            Button(step == lastStep ? "Finish" : "Continue") {
                if step == lastStep { finish() }
                else { withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { step += 1 } }
            }
            .buttonStyle(.plain)
            .font(.system(size: 13, weight: .semibold)).foregroundColor(Gruv.bg0h)
            .padding(.horizontal, 18).padding(.vertical, 9)
            .background(RoundedRectangle(cornerRadius: 9).fill(Gruv.orange))
        }
        .padding(.horizontal, 24).padding(.vertical, 16)
        .background(Gruv.bg0h.opacity(0.6))
    }

    // MARK: Permissions

    private func refreshPermissions() {
        let s = CGPreflightScreenCaptureAccess()
        let a = AXIsProcessTrusted()
        if s != screenOK || a != axOK {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { screenOK = s; axOK = a }
        }
    }

    private func requestScreen() {
        if !CGRequestScreenCaptureAccess() {
            NSWorkspace.shared.open(URL(string:
                "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!)
        }
    }

    private func requestAX() {
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        if !AXIsProcessTrustedWithOptions(opts) {
            NSWorkspace.shared.open(URL(string:
                "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }

    private func finish() {
        guard !exiting else { return }
        settings.hasOnboarded = true
        // Fade the whole overlay out, then tear down the window.
        withAnimation(.easeOut(duration: 0.38)) { exiting = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { onFinish() }
    }
}

// MARK: - Vsync-animated aurora background

/// Soft drifting color blobs, recomputed every display frame via
/// TimelineView(.animation) — i.e. updated at the screen's refresh rate (vsync).
private struct AuroraBackground: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            GeometryReader { geo in
                let w = geo.size.width, h = geo.size.height
                ZStack {
                    Gruv.bg0h
                    blob(Gruv.orange, w, h, phase: t * 0.18, ox: 0.30, oy: 0.28, r: 0.55)
                    blob(Gruv.aqua,   w, h, phase: t * 0.13 + 2, ox: 0.72, oy: 0.34, r: 0.50)
                    blob(Gruv.yellow, w, h, phase: t * 0.21 + 4, ox: 0.55, oy: 0.74, r: 0.48)
                    blob(Gruv.red,    w, h, phase: t * 0.11 + 1, ox: 0.22, oy: 0.70, r: 0.42)
                }
                .blur(radius: 90)
                .overlay(Color.black.opacity(0.18)) // settle contrast under the card
            }
        }
        .drawingGroup() // composite the blur once per frame on the GPU
    }

    private func blob(_ color: Color, _ w: CGFloat, _ h: CGFloat,
                      phase: Double, ox: CGFloat, oy: CGFloat, r: CGFloat) -> some View {
        let dx = CGFloat(sin(phase)) * w * 0.10
        let dy = CGFloat(cos(phase * 1.2)) * h * 0.10
        let size = min(w, h) * r
        return Circle()
            .fill(color.opacity(0.38))
            .frame(width: size, height: size)
            .position(x: w * ox + dx, y: h * oy + dy)
    }
}

// MARK: - Animated logo (scissors snipping a dashed line)

private struct SnipMark: View {
    @State private var snip = false
    @State private var pop = false

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                dashes.opacity(snip ? 0.25 : 1)
                Spacer().frame(width: 76)
                dashes.opacity(snip ? 1 : 0.25)
            }
            .frame(width: 220)

            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Gruv.orange)
                .frame(width: 76, height: 76)
                .overlay(
                    Image(systemName: "scissors")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Gruv.bg0h)
                        .rotationEffect(.degrees(snip ? -8 : 8)))
                .scaleEffect(pop ? 1 : 0.4)
                .rotationEffect(.degrees(pop ? 0 : -12))
                .shadow(color: Gruv.orange.opacity(0.45), radius: snip ? 18 : 8)
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.5)) { pop = true }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true).delay(0.4)) { snip = true }
        }
    }

    private var dashes: some View {
        HStack(spacing: 5) {
            ForEach(0..<6, id: \.self) { _ in
                Capsule().fill(Gruv.bg3).frame(width: 9, height: 3)
            }
        }
    }
}

// MARK: - Interactive "try it" step

private struct TryItStep: View {
    @EnvironmentObject var settings: AppSettings
    @State private var cmdDone = false
    @State private var ctrlDone = false
    @State private var sawShift = false
    @State private var confetti = 0
    @State private var monitor: Any?

    @State private var cmdWasDown = false
    @State private var ctrlWasDown = false
    @State private var lastCmd = Date.distantPast
    @State private var lastCtrl = Date.distantPast

    private var bothDone: Bool { cmdDone && ctrlDone }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 14) {
                stepTitle
                Text("Tap each modifier **twice, quickly** — right here. Go on, your keyboard is listening.")
                    .font(.system(size: 13)).foregroundColor(Gruv.fg3)
                    .fixedSize(horizontal: false, vertical: true)

                gestureCard(symbol: "command", label: "Tap ⌘ twice",
                            hint: "captures a screen region", done: cmdDone, tint: Gruv.aqua)
                gestureCard(symbol: "control", label: "Tap ⌃ twice",
                            hint: "shares your selected text", done: ctrlDone, tint: Gruv.yellow)

                Card {
                    HStack(spacing: 10) {
                        Image(systemName: sawShift ? "wand.and.stars" : "shift")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(sawShift ? Gruv.green : Gruv.gray)
                            .frame(width: 18)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Pro move: hold ⇧ while you double-tap")
                                .font(.system(size: 12, weight: .medium)).foregroundColor(Gruv.fg1)
                            Text(sawShift
                                 ? "Nice — that's the raw share. Skips the styled window."
                                 : "Shares text raw, skipping Nab's styled window image.")
                                .font(.system(size: 11)).foregroundColor(sawShift ? Gruv.green : Gruv.gray)
                        }
                        Spacer()
                    }
                }

                Text(bothDone
                     ? "You've got it. That muscle memory works everywhere — not just here."
                     : "No uploads happen on this screen — it's just practice.")
                    .font(.system(size: 11))
                    .foregroundColor(bothDone ? Gruv.green : Gruv.gray)
                    .animation(.easeInOut, value: bothDone)
                Spacer()
            }
            ConfettiBurst().id(confetti)
        }
        .onAppear(perform: startMonitor)
        .onDisappear(perform: stopMonitor)
    }

    private var stepTitle: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text("Try it").font(.mono(20, weight: .bold)).foregroundColor(Gruv.fg0)
                if bothDone {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(Gruv.green).font(.system(size: 18))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            Text("The whole app is two gestures. Let's build the muscle memory now.")
                .font(.system(size: 13)).foregroundColor(Gruv.fg3)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: bothDone)
    }

    private func gestureCard(symbol: String, label: String, hint: String, done: Bool, tint: Color) -> some View {
        Card {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(done ? Gruv.green : tint)
                        .frame(width: 34, height: 34)
                    Image(systemName: done ? "checkmark" : symbol)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Gruv.bg0h)
                }
                .scaleEffect(done ? 1.08 : 1)
                .animation(.spring(response: 0.35, dampingFraction: 0.45), value: done)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label).font(.system(size: 13, weight: .semibold)).foregroundColor(Gruv.fg1)
                    Text(done ? "Got it — nicely done" : hint)
                        .font(.system(size: 11)).foregroundColor(done ? Gruv.green : Gruv.gray)
                }
                Spacer()
                if done {
                    Text("✓").font(.system(size: 14, weight: .bold)).foregroundColor(Gruv.green)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(done ? Gruv.green.opacity(0.6) : .clear, lineWidth: 1.5))
    }

    private func startMonitor() {
        guard monitor == nil else { return }
        monitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
            handle(event); return event
        }
    }

    private func stopMonitor() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
    }

    private func handle(_ event: NSEvent) {
        let f = event.modifierFlags
        let cmd = f.contains(.command)
        let ctrl = f.contains(.control)
        let shift = f.contains(.shift)
        let gap: TimeInterval = max(0.18, settings.doubleCmdGap / 1000)

        if cmd && !cmdWasDown {
            let now = Date()
            if now.timeIntervalSince(lastCmd) <= gap, !cmdDone { complete(isCmd: true, shift: shift) }
            lastCmd = now
        }
        cmdWasDown = cmd

        if ctrl && !ctrlWasDown {
            let now = Date()
            if now.timeIntervalSince(lastCtrl) <= gap, !ctrlDone { complete(isCmd: false, shift: shift) }
            lastCtrl = now
        }
        ctrlWasDown = ctrl
    }

    private func complete(isCmd: Bool, shift: Bool) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            if isCmd { cmdDone = true } else { ctrlDone = true }
            if shift { sawShift = true }
        }
        confetti += 1
        NSSound(named: "Pop")?.play()
    }
}

// MARK: - Confetti

private struct ConfettiBurst: View {
    var count = 26
    @State private var fired = false
    @State private var pieces: [Piece] = []

    private struct Piece: Identifiable {
        let id = UUID()
        let dx: CGFloat, dy: CGFloat, size: CGFloat, rotation: Double, color: Color
    }
    private let palette = [Gruv.orange, Gruv.yellow, Gruv.green, Gruv.aqua, Gruv.blue, Gruv.red]

    var body: some View {
        ZStack {
            ForEach(pieces) { p in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(p.color)
                    .frame(width: p.size, height: p.size * 0.55)
                    .rotationEffect(.degrees(fired ? p.rotation : 0))
                    .offset(x: fired ? p.dx : 0, y: fired ? p.dy : 0)
                    .opacity(fired ? 0 : 1)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            pieces = (0..<count).map { _ in
                let angle = Double.random(in: 0..<(2 * .pi))
                let dist = CGFloat.random(in: 70...190)
                return Piece(
                    dx: cos(angle) * dist,
                    dy: sin(angle) * dist - 30,
                    size: .random(in: 6...11),
                    rotation: .random(in: -300...300),
                    color: palette.randomElement()!)
            }
            withAnimation(.easeOut(duration: 0.95)) { fired = true }
        }
    }
}
