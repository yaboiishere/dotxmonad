--
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--
{-# LANGUAGE ImportQualifiedPost #-}

import Data.List (sortOn)
import Data.Map qualified as M
import Data.Maybe (fromMaybe)
import Graphics.X11.ExtraTypes
import System.Directory.Internal.Prelude (lookupEnv)
import System.Exit (exitSuccess)
import XMonad
import XMonad.Actions.SpawnOn (manageSpawn)
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)
import XMonad.Hooks.ManageDocks (AvoidStruts, ToggleStruts (..), avoidStruts, docks)
import XMonad.Layout.Decoration (ModifiedLayout)
import XMonad.Layout.Fullscreen (fullscreenEventHook)
import XMonad.Prelude (All, elemIndex)
import XMonad.StackSet qualified as W
import XMonad.Util.Run (safeSpawn)
import XMonad.Util.SpawnOnce (spawnOnOnce, spawnOnce)
import Prelude

-- Tpe preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal :: String
myTerminal = "alacritty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth :: Dimension
myBorderWidth = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask :: KeyMask
myModMask = mod4Mask

altMask :: KeyMask
altMask = mod1Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces :: [String]
myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor :: String
myNormalBorderColor = "pink"

myFocusedBorderColor :: String
myFocusedBorderColor = "purple"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modm}) =
  M.fromList $
    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf),
      -- launch dmenu
      ((modm, xK_d), spawn "rofi -combi-modi window,drun,ssh -theme solarized -font \"hack 10\" -show combi"),
      -- close focused window
      ((modm .|. shiftMask, xK_q), kill),
      -- Rotate through the available layout algorithms
      ((modm, xK_space), sendMessage NextLayout),
      --  Reset the layouts on the current workspace to default
      ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf),
      -- Resize viewed windows to the correct size
      ((modm, xK_n), refresh),
      -- Move focus to the next window
      ((modm, xK_Tab), windows W.focusDown),
      -- Move focus to the next window
      ((modm, xK_j), windows W.focusDown),
      -- Move focus to the previous window
      ((modm .|. shiftMask, xK_Tab), windows W.focusUp),
      -- Move focus to the previous window
      ((modm, xK_k), windows W.focusUp),
      -- Move focus to the master window
      ((modm, xK_m), windows W.focusMaster),
      -- Swap the focused window and the master window
      ((modm, xK_Return), windows W.swapMaster),
      -- Swap the focused window with the next window
      ((modm .|. shiftMask, xK_j), windows W.swapDown),
      -- Swap the focused window with the previous window
      ((modm .|. shiftMask, xK_k), windows W.swapUp),
      -- Shrink the master area
      ((modm, xK_h), sendMessage Shrink),
      -- Expand the master area
      ((modm, xK_l), sendMessage Expand),
      -- Push window back into tiling
      ((modm, xK_t), withFocused $ windows . W.sink),
      -- Increment the number of windows in the master area
      ((modm, xK_comma), sendMessage (IncMasterN 1)),
      -- Deincrement the number of windows in the master area
      ((modm, xK_period), sendMessage (IncMasterN (-1))),
      -- Toggle the status bar gap
      -- Use this binding with avoidStruts from Hooks.ManageDocks.
      -- See also the statusBar function from Hooks.DynamicLog.
      --
      ((modm, xK_b), sendMessage ToggleStruts),
      -- Quit xmonad
      ((modm .|. shiftMask, xK_t), io exitSuccess),
      -- Restart xmonad
      ((modm, xK_c), spawn "xmonad --recompile; xmonad --restart"),
      -- Run xmessage with a summary of the default keybindings (useful for beginners)
      ((modm .|. shiftMask, xK_slash), spawn ("echo \"" ++ help ++ "\" | xmessage -file -")),
      -- Screenshot
      ((0, xK_Print), spawn "flameshot gui"),
      ((modm, xK_Print), spawn "flameshot screen -p ~/Pictures"),
      ((modm .|. shiftMask, xK_s), spawn "flameshot gui"),
      -- Clipboard rofi-greenclip
      ((modm, xK_v), spawn "rofi -modi \"clipboard:greenclip print\" -show clipboard -run-command '{cmd}'"),
      -- Media Keys
      ((0, xF86XK_AudioLowerVolume), spawn "amixer -q set Master 5%-"),
      ((0, xF86XK_AudioRaiseVolume), spawn "amixer -q set Master 5%+"),
      ((0, xF86XK_AudioMute), spawn "amixer -q set Master toggle"),
      ((0, xF86XK_AudioMicMute), spawn "amixer -q set Capture toggle"),
      ((0, xF86XK_AudioPlay), spawn "playerctl play-pause"),
      ((0, xF86XK_AudioNext), spawn "playerctl next"),
      ((0, xF86XK_AudioPrev), spawn "playerctl previous"),
      ((0, xF86XK_AudioStop), spawn "playerctl stop"),
      ((0, xF86XK_MonBrightnessUp), spawn "light -A 5"),
      ((0, xF86XK_MonBrightnessDown), spawn "light -U 5"),
      ((altMask, xK_Shift_L), spawn "~/.config/scripts/cycle-keyboard-layout us bg")
    ]
      ++
      --
      -- mod-[1..9], Switch to workspace N
      -- mod-shift-[1..9], Move client to workspace N
      --
      [ ((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) $ [xK_1 .. xK_9] ++ [xK_0],
          (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
      ]
      ++
      --
      -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
      -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
      --
      [ ((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_e, xK_w, xK_r] [0 ..],
          (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
      ]

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--

myMouseBindings :: XConfig Layout -> M.Map (KeyMask, Button) (Window -> X ())
myMouseBindings (XConfig {XMonad.modMask = modm}) =
  M.fromList
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ( (modm, button1),
        \w ->
          focus w
            >> mouseMoveWindow w
            >> windows W.shiftMaster
      ),
      -- mod-button2, Raise the window to the top of the stack
      ((modm, button2), \w -> focus w >> windows W.shiftMaster),
      -- mod-button3, Set the window to floating mode and resize by dragging
      ( (modm, button3),
        \w ->
          focus w
            >> mouseResizeWindow w
            >> windows W.shiftMaster
      )
      -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
myLayout :: ModifiedLayout AvoidStruts (Choose Tall (Choose (Mirror Tall) Full)) a
myLayout = avoidStruts (tiled ||| Mirror tiled ||| Full)
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled = Tall nmaster delta ratio

    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio = 1 / 2

    -- Percent of screen to increment by when resizing panes
    delta = 3 / 100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.

myManageHook :: ManageHook
myManageHook =
  manageSpawn
    <+> composeAll
      [ className =? "MPlayer" --> doFloat,
        className =? "Gimp" --> doFloat,
        resource =? "desktop_window" --> doIgnore,
        resource =? "kdesktop" --> doIgnore
      ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook

--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.

myEventHook :: Event -> X All
myEventHook = fullscreenEventHook

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook :: X ()
myStartupHook = do
  spawn "~/.config/polybar/launch.sh"
  spawnOnce "deadd-notification-center &"
  spawnOnce "flameshot &"
  spawn "greenclip daemon &"

  spawnOnOnce "2" "google-chrome-stable --profile-directory='Profile 1'"
  spawnOnOnce "8" "thunderbird"
  spawnOnOnce "8" "mattermost-desktop"
  spawnOnOnce "0" "google-chrome-stable --profile-directory=Default"
  spawnOnOnce "9" "discord"
  spawnOnOnce "9" "spotify"

main :: IO ()
main = do
  mode <- fromMaybe "xmonad" <$> lookupEnv "XMONAD_MODE"
  _ <- spawn "rm -f /tmp/xmonad"
  let workspaceNameFile = "/tmp/" <> mode
  safeSpawn "mkfifo" ["--mode=a=rwx", workspaceNameFile]
  xmonad $
    ewmh $
      docks $
        ewmhFullscreen $
          def
            { logHook = sendWorkspaceNames workspaceNameFile,
              -- simple stuff
              terminal = myTerminal,
              focusFollowsMouse = myFocusFollowsMouse,
              clickJustFocuses = myClickJustFocuses,
              borderWidth = myBorderWidth,
              modMask = myModMask,
              workspaces = myWorkspaces,
              normalBorderColor = myNormalBorderColor,
              focusedBorderColor = myFocusedBorderColor,
              -- key bindings
              keys = myKeys,
              mouseBindings = myMouseBindings,
              -- hooks, layouts
              layoutHook = myLayout,
              -- logHook = dynamicLogIconsWithPP myIcons $ myLogHook dbus,
              manageHook = myManageHook,
              handleEventHook = myEventHook,
              startupHook = myStartupHook
            }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help =
  unlines
    [ "The default modifier key is 'alt'. Default keybindings:",
      "",
      "-- launching and killing programs",
      "mod-Shift-Enter  Launch xterminal",
      "mod-p            Launch dmenu",
      "mod-Shift-p      Launch gmrun",
      "mod-Shift-c      Close/kill the focused window",
      "mod-Space        Rotate through the available layout algorithms",
      "mod-Shift-Space  Reset the layouts on the current workSpace to default",
      "mod-n            Resize/refresh viewed windows to the correct size",
      "",
      "-- move focus up or down the window stack",
      "mod-Tab        Move focus to the next window",
      "mod-Shift-Tab  Move focus to the previous window",
      "mod-j          Move focus to the next window",
      "mod-k          Move focus to the previous window",
      "mod-m          Move focus to the master window",
      "",
      "-- modifying the window order",
      "mod-Return   Swap the focused window and the master window",
      "mod-Shift-j  Swap the focused window with the next window",
      "mod-Shift-k  Swap the focused window with the previous window",
      "",
      "-- resizing the master/slave ratio",
      "mod-h  Shrink the master area",
      "mod-l  Expand the master area",
      "",
      "-- floating layer support",
      "mod-t  Push window back into tiling; unfloat and re-tile it",
      "",
      "-- increase or decrease number of windows in the master area",
      "mod-comma  (mod-,)   Increment the number of windows in the master area",
      "mod-period (mod-.)   Deincrement the number of windows in the master area",
      "",
      "-- quit, or restart",
      "mod-Shift-q  Quit xmonad",
      "mod-q        Restart xmonad",
      "mod-[1..9]   Switch to workSpace N",
      "",
      "-- Workspaces & screens",
      "mod-Shift-[1..9]   Move client to workspace N",
      "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
      "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
      "",
      "-- Mouse bindings: default actions bound to mouse events",
      "mod-button1  Set the window to floating mode and move by dragging",
      "mod-button2  Raise the window to the top of the stack",
      "mod-button3  Set the window to floating mode and resize by dragging"
    ]

windowIcons :: [Window] -> X [String]
windowIcons winIds = do
  dis <- display <$> ask
  windowClasses <- io $ mapM (fmap resClass . getClassHint dis) winIds
  return $ map (\win -> fromMaybe "\xf2d0" (M.lookup win myWindowIcons)) windowClasses

joinWithSpaces :: Int -> [String] -> String
joinWithSpaces spaces = joinStrings $ replicate spaces ' '

joinStrings :: String -> [String] -> String
joinStrings joinWith = Prelude.foldr (\a b -> a <> joinWith <> b) ""

clickable :: String -> String -> String
clickable winId str =
  "%{A:xdotool key Super+"
    <> winId
    <> ":}"
    <> str
    <> "%{A}"

highlight :: String -> String
highlight = fg "#FFFFFF"

normal :: String -> String
normal = fg "#777777"

fg :: String -> String -> String
fg colour str = "%{F" <> colour <> "}" <> str <> "%{F-}"

myWindowIcons :: M.Map String String
myWindowIcons =
  M.fromList
    [ ("Alacritty", "\xf120"),
      ("firefox", "\xf269"),
      ("Brave-browser", "\xf268"),
      ("Chromium", "\xf268"),
      ("Google-chrome", "\xf268"),
      ("Blueberry.py", "\xf294"),
      ("libreoffice-startcenter", "\xf15c"),
      ("libreoffice-draw", "\xf15c"),
      ("Steam", "\xf1b6"),
      ("Spotify", "\xf1bc"),
      ("Inkscape", "\xf6fc"),
      ("Kodi", "\xf03d"),
      ("Transmission-gtk", "\xf019"),
      ("Zotero", "\xf02d"),
      ("Signal", "\xfceb"),
      ("thunderbird", "\xf0e0"),
      ("discord", "\xf392"),
      ("Postman", "\xf1d8"),
      ("Slack", "\xf9b0"),
      ("vlc", "\xfa7b"),
      ("mpv", "\xf03d"),
      ("dolphin", "\xf413"),
      ("Rocket.Chat", "\xf3e8"),
      ("Telegram", "\xf2c6"),
      ("TelegramDesktop", "\xf2c6")
    ]

sendWorkspaceNames :: String -> X ()
sendWorkspaceNames file = do
  workspacesString <- joinWithSpaces 1 <$> prettyWorkspaceList
  io $ appendFile file $ workspacesString ++ "  \n"

prettyWorkspaceList :: X [String]
prettyWorkspaceList = do
  curWorkspaces <- sortOn W.tag . filter (\wspace -> W.tag wspace /= "NSP") . W.workspaces . windowset <$> get
  workspaceIcons <- filter (\(_, icons) -> not $ Prelude.null icons) . zip (map W.tag curWorkspaces) <$> mapM prettyWindowIconList curWorkspaces
  focusedWspace <- W.tag . W.workspace . W.current . windowset <$> get
  let colour tag = (if tag == focusedWspace then highlight else normal)
  return $ map (\(tag, winIcons) -> colour tag $ clickable tag $ joinWithSpaces 2 (tag : winIcons)) workspaceIcons

prettyWindowIconList :: W.Workspace WorkspaceId l Window -> X [String]
prettyWindowIconList workspace = case W.stack workspace of
  Nothing -> return []
  Just curStack -> do
    let curWindows = W.integrate curStack
    winIcons <- windowIcons curWindows
    let focusedIndex = fromMaybe (-1) $ elemIndex (W.focus curStack) curWindows
    isWorkspaceFocused <- (==) (W.tag workspace) . W.tag . W.workspace . W.current . windowset <$> get
    return $ reverse $ zipWith (\icon i -> if i == focusedIndex && isWorkspaceFocused then highlight icon else normal icon) winIcons [0 ..]
