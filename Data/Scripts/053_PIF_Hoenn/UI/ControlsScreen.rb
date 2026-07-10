# #TODO: Finish implementing
#
# #===============================================================================
# # * Set the Controls Screen - by FL (Credits will be apreciated)
# #===============================================================================
# #
# # This script is for Pokémon Essentials. It creates a "Set the controls" screen
# # on pause menu, allowing the player to map the actions to the keys in keyboard
# # and buttons in a gamepad, ignoring the values defined on F1. You can also
# # define the default controls.
# #
# #== INSTALLATION ===============================================================
# #
# # To this script works, put it above main OR convert into a plugin.
# #
# #== NOTES ======================================================================
# #
# # Look at 'self.default_controls' and below for default controls and default
# # names.
# #
# # '$PokemonSystem.game_controls = nil' resets the controls.
# #
# # 'SetControls.open_ui' opens the control UI. You can call it from places like
# # an event.
# #
# # This script, by default, doesn't allow the player to redefine some commands
# # like F8 (screenshot key), but if the player assign an action to this key,
# # like the "Cancel" action, this key will do this action AND take screenshots
# # when pressed. Remember that F12 will reset the game.
# #
# # You can comment keys/buttons in KEYBOARD_LIST (and gamepad ones) to remove
# # the key as available key for user. Remember to remove it from default
# # controls if it is in the list.
# #
# # To add more actions, look the lines in this script where there is a
# # "Ready Menu" in, for example and do the same thing. You need to use defined
# # values in Input (like Input::SPECIAL, used in Ready Menu case or the unused
# # Input::AUX1 and Input::AUX2). This script also creates AUX3, AUX4 and AUX5,
# # but you can create more (just follows AUX5 format).
# #
# # 'SetControls.key_array(act)' return the key/button array, where act is the
# # action name (like "Cancel"). You can use it to set in a variable and inform
# # player of a certain key/button, example in an event:
# #
# #   @>Script: $game_variables[42] =
# #           :   SetControls.key_array("Cancel")[0]
# #   @>Text: Press \v[42] to exit from menus.
# #
# #===============================================================================
#
# if !PluginManager.installed?("Set the Controls Screen")
#   PluginManager.register({
#                            :name    => "Set the Controls Screen",
#                            :version => "1.2.8",
#                            :link    => "https://www.pokecommunity.com/showthread.php?t=309391",
#                            :credits => "FL"
#                          })
# end
#
# module SetControls
#   # Change it to false for easily disable this script, without affecting saves.
#   # After changing this value, close and open the game window.
#   ENABLED = true
#
#   # Automatic sort the keys by index. This way gamepad buttons always goes last.
#   AUTO_SORT = true
#
#   # Control screen won't allow player to add more keys/button to a single
#   # action after reaching at this number.
#   MAX_KEYS_PER_ACTION = 9
# end
#
# # Class stored in saves.
# class ControlConfig
#   attr_reader :control_action
#   attr_accessor :key_code
#
#   def initialize(control_action, key=nil)
#     @control_action = control_action
#     @key_code = Keys.key_code(key) if key
#   end
#
#   def self.new_by_code(control_action, key_code)
#     ret = self.new(control_action)
#     ret.key_code = key_code
#     return ret
#   end
#
#   # Create multiple per key and return an array with new initialized instances
#   def self.multiple_new(control_action, key_array)
#     return key_array.map{|key| self.new(control_action,key)}
#   end
#
#   def key_name
#     return Keys.key_name(@key_code)
#   end
# end
#
# module Input
#   AUX3 = 53
#   AUX4 = 54
#   AUX5 = 55
#
#   AXIS_ENABLED = true
#   # Used offsets to support the same variable for both gamepad and keyboard.
#   GAMEPAD_OFFSET = 500
#   AXIS_OFFSET = 100 + GAMEPAD_OFFSET
#   AXIS_THRESHOLD = 0.5
#   AXIS_REPEAT_INITIAL_DELAY = 0.5
#   AXIS_REPEAT_DELAY = 0.1
#
#   # Using this for manual check
#   LEFT_STICK_LEFT   = 0x00
#   LEFT_STICK_RIGHT  = 0x01
#   LEFT_STICK_UP     = 0x02
#   LEFT_STICK_DOWN   = 0x03
#   RIGHT_STICK_LEFT  = 0x04
#   RIGHT_STICK_RIGHT = 0x05
#   RIGHT_STICK_UP    = 0x06
#   RIGHT_STICK_DOWN  = 0x07
#   LEFT_TRIGGER      = 0x09
#   RIGHT_TRIGGER     = 0x0B
#   AXIS_COUNT        = RIGHT_TRIGGER+1
#
#   class << self
#     if !method_defined?(:_old_fl_press?)
#       alias :_old_fl_press? :press?
#       def press?(button)
#         key = buttonToKey(button)
#         return key ? pressex_array?(key) : _old_fl_press?(button)
#       end
#
#       alias :_old_fl_trigger? :trigger?
#       def trigger?(button)
#         key = buttonToKey(button)
#         return key ? triggerex_array?(key) : _old_fl_trigger?(button)
#       end
#
#       alias :_old_fl_repeat? :repeat?
#       def repeat?(button)
#         key = buttonToKey(button)
#         return key ? repeatex_array?(key) : _old_fl_repeat?(button)
#       end
#
#       alias :_old_fl_release? :release?
#       def release?(button)
#         key = buttonToKey(button)
#         return key ? releaseex_array?(key) : _old_fl_release?(button)
#       end
#     end
#
#     def pressex_array?(array)
#       for item in array
#         if item >= AXIS_OFFSET
#           return true if axis_pressex?(item - AXIS_OFFSET)
#         elsif item >= GAMEPAD_OFFSET
#           return true if Controller.pressex?(item - GAMEPAD_OFFSET)
#         else
#           return true if pressex?(item)
#         end
#       end
#       return false
#     end
#
#     def triggerex_array?(array)
#       for item in array
#         if item >= AXIS_OFFSET
#           return true if axis_triggerex?(item - AXIS_OFFSET)
#         elsif item >= GAMEPAD_OFFSET
#           return true if Controller.triggerex?(item - GAMEPAD_OFFSET)
#         else
#           return true if triggerex?(item)
#         end
#       end
#       return false
#     end
#
#     def repeatex_array?(array)
#       for item in array
#         if item >= AXIS_OFFSET
#           # Trigger is checked in axis_repeatex?
#           return true if axis_repeatex?(item - AXIS_OFFSET)
#         elsif item >= GAMEPAD_OFFSET
#           return true if Controller.repeatex?(item - GAMEPAD_OFFSET)
#           return true if Controller.triggerex?(item - GAMEPAD_OFFSET)
#         else
#           return true if repeatex?(item)
#           return true if triggerex?(item)
#         end
#       end
#       return false
#     end
#
#     def releaseex_array?(array)
#       for item in array
#         if item >= AXIS_OFFSET
#           return true if axis_releaseex?(item - AXIS_OFFSET)
#         elsif item >= GAMEPAD_OFFSET
#           return true if Controller.releaseex?(item - GAMEPAD_OFFSET)
#         else
#           return true if releaseex?(item)
#         end
#       end
#       return false
#     end
#
#     def dir4
#       return 0 if press?(DOWN) && press?(UP)
#       return 0 if press?(LEFT) && press?(RIGHT)
#       for button in [DOWN,LEFT,RIGHT,UP]
#         return button if press?(button)
#       end
#       return 0
#     end
#
#     def dir8
#       buttons = []
#       for b in [DOWN,LEFT,RIGHT,UP]
#         buttons.push(b) if press?(b)
#       end
#       if buttons.length==0
#         return 0
#       elsif buttons.length==1
#         return buttons[0]
#       elsif buttons.length==2
#         return 0 if (buttons[0]==DOWN && buttons[1]==UP)
#         return 0 if (buttons[0]==LEFT && buttons[1]==RIGHT)
#       end
#       up_down    = 0
#       left_right = 0
#       for b in buttons
#         up_down    = b if up_down==0 && (b==UP || b==DOWN)
#         left_right = b if left_right==0 && (b==LEFT || b==RIGHT)
#       end
#       if up_down==DOWN
#         return 1 if left_right==LEFT
#         return 3 if left_right==RIGHT
#         return 2
#       elsif up_down==UP
#         return 7 if left_right==LEFT
#         return 9 if left_right==RIGHT
#         return 8
#       else
#         return 4 if left_right==LEFT
#         return 6 if left_right==RIGHT
#         return 0
#       end
#     end
#
#     def buttonToKey(button)
#       $PokemonSystem = PokemonSystem.new if !$PokemonSystem
#       return case button
#              when Input::DOWN
#                $PokemonSystem.game_control_code("Down")
#              when Input::LEFT
#                $PokemonSystem.game_control_code("Left")
#              when Input::RIGHT
#                $PokemonSystem.game_control_code("Right")
#              when Input::UP
#                $PokemonSystem.game_control_code("Up")
#              when Input::ACTION # Z, W, Y, Shift
#                $PokemonSystem.game_control_code("Run")
#              when Input::BACK # X, ESC
#                $PokemonSystem.game_control_code("Cancel")
#              when Input::USE # C, ENTER, Space
#                $PokemonSystem.game_control_code("Action")
#              when Input::JUMPUP # A, Q, Page Up
#                $PokemonSystem.game_control_code("Scroll Up")
#              when Input::JUMPDOWN # S, Page Down
#                $PokemonSystem.game_control_code("Scroll Down")
#              when Input::SPECIAL # F, F5, Tab
#                $PokemonSystem.game_control_code("Ready Menu")
#                # when Input::AUX1
#                #   $PokemonSystem.game_control_code("Example A")
#                # when Input::AUX2
#                #   $PokemonSystem.game_control_code("Example B")
#                when Input::AUX3
#                  $PokemonSystem.game_control_code("Speed Up")
#                # when Input::AUX4
#                #   $PokemonSystem.game_control_code("Example D")
#                # when Input::AUX5
#                #   $PokemonSystem.game_control_code("Example E")
#              else
#                nil
#              end
#     end
#
#     @@axis_states = Array.new(AXIS_COUNT, false)
#     @@axis_states_old      = @@axis_states.clone
#     @@axis_states_trigger  = @@axis_states.clone
#     @@axis_states_repeat   = @@axis_states.clone
#     @@axis_states_release  = @@axis_states.clone
#     @@axis_states_trigger_time = Array.new(@@axis_states.size, 0.0)
#     @@axis_states_repeat_time = Array.new(@@axis_states.size, 0.0)
#
#     def refresh_axis_array
#       for i in 0...@@axis_states.size
#         @@axis_states_old[i] = @@axis_states[i]
#         @@axis_states[i] = axis_state(i) > AXIS_THRESHOLD
#         @@axis_states_trigger[i]=  @@axis_states[i] && !@@axis_states_old[i]
#         @@axis_states_release[i]= !@@axis_states[i] &&  @@axis_states_old[i]
#         @@axis_states_trigger_time[i]= System.uptime if @@axis_states_trigger[i]
#         @@axis_states_repeat[i] = @@axis_states_trigger[i] || (
#           @@axis_states[i] && (
#             System.uptime >= @@axis_states_trigger_time[i] + AXIS_REPEAT_INITIAL_DELAY
#           ) && System.uptime >= @@axis_states_repeat_time[i] + AXIS_REPEAT_DELAY
#         )
#         @@axis_states_repeat_time[i] = System.uptime if @@axis_states_repeat[i]
#       end
#     end
#
#     def axis_state(key)
#       return case key
#              when LEFT_STICK_LEFT;   -Controller.axes_left[0]
#              when LEFT_STICK_RIGHT;   Controller.axes_left[0]
#              when LEFT_STICK_UP;     -Controller.axes_left[1]
#              when LEFT_STICK_DOWN;    Controller.axes_left[1]
#              when RIGHT_STICK_LEFT;  -Controller.axes_right[0]
#              when RIGHT_STICK_RIGHT;  Controller.axes_right[0]
#              when RIGHT_STICK_UP;    -Controller.axes_right[1]
#              when RIGHT_STICK_DOWN;   Controller.axes_right[1]
#              when LEFT_TRIGGER;       Controller.axes_trigger[0]
#              when RIGHT_TRIGGER;      Controller.axes_trigger[1]
#              else 0
#              end
#     end
#
#     def axis_pressex?(index)
#       return @@axis_states[index]
#     end
#     def axis_triggerex?(index)
#       return @@axis_states_trigger[index]
#     end
#     def axis_repeatex?(index)
#       return @@axis_states_repeat[index]
#     end
#     def axis_releaseex?(index)
#       return @@axis_states_release[index]
#     end
#
#     # For compatibility with other scripts, use update_KGC_ScreenCapture
#     # instead of Input.update
#     if (
#       AXIS_ENABLED &&
#         defined?(Controller) && !method_defined?(:_old_fl_update_kgc)
#     )
#       alias :_old_fl_update_kgc :update_KGC_ScreenCapture
#       def update_KGC_ScreenCapture
#         _old_fl_update_kgc
#         refresh_axis_array
#       end
#     end
#   end
# end if SetControls::ENABLED
#
# module Keys
#   # Here you can change the default values
#   def self.default_controls
#     return default_controls_no_gamepad if !Input.const_defined?(:Controller)
#     return (
#       ControlConfig.multiple_new("Down", ["Down","D-Pad Down","L-Stick Down"]) +
#         ControlConfig.multiple_new("Left", ["Left","D-Pad Left","L-Stick Left"]) +
#         ControlConfig.multiple_new("Right", ["Right", "D-Pad Right", "L-Stick Right"]) +
#         ControlConfig.multiple_new("Up", ["Up", "D-Pad Up","L-Stick Up"]) +
#         ControlConfig.multiple_new("Action", ["C","Enter","Space", "Button A"]) +
#         ControlConfig.multiple_new("Cancel / Menu", ["X","Esc", "Numpad 0", "Button B"])+
#         ControlConfig.multiple_new("Run", ["Z", "Shift", "Button X"]) +
#         ControlConfig.multiple_new("Scroll Up", ["A", "Left Shoulder"]) +
#         ControlConfig.multiple_new("Scroll Down", ["S", "Right Shoulder"]) +
#         ControlConfig.multiple_new("Ready Menu", ["D","Button Y"]) +
#         ControlConfig.multiple_new("Speed Up", ["F", "Right Stick"])
#     )
#   end
#
#   def self.default_controls_no_gamepad
#     return (
#       ControlConfig.multiple_new("Down", ["Down"]) +
#         ControlConfig.multiple_new("Left", ["Left"]) +
#         ControlConfig.multiple_new("Right", ["Right"]) +
#         ControlConfig.multiple_new("Up", ["Up"]) +
#         ControlConfig.multiple_new("Action", ["C","Enter","Space"]) +
#         ControlConfig.multiple_new("Cancel / Menu", ["X","Esc"])+
#         ControlConfig.multiple_new("Run", ["Z", "Shift"]) +
#         ControlConfig.multiple_new("Scroll Up", ["A"]) +
#         ControlConfig.multiple_new("Scroll Down", ["S"]) +
#         ControlConfig.multiple_new("Ready Menu", ["D"]) +
#         ControlConfig.multiple_new("Speed Up", ["F"])
#     )
#   end
#
#   # Available keys in keyboard
#   KEYBOARD_LIST = {
#     # Mouse buttons
#     "Backspace"    => 0x08,
#     "Tab"          => 0x09,
#     "Clear"        => 0x0C,
#     "Enter"        => 0x0D,
#     "Shift"        => 0x10,
#     "Ctrl"         => 0x11,
#     "Alt"          => 0x12,
#     "Pause"        => 0x13,
#     # IME keys
#     "Caps Lock"    => 0x14,
#     "Esc"          => 0x1B,
#     "Space"        => 0x20,
#     "Page Up"      => 0x21,
#     "Page Down"    => 0x22,
#     "End"          => 0x23,
#     "Home"         => 0x24,
#     "Left"         => 0x25,
#     "Up"           => 0x26,
#     "Right"        => 0x27,
#     "Down"         => 0x28,
#     "Select"       => 0x29,
#     "Print"        => 0x2A,
#     "Execute"      => 0x2B,
#     "Print Screen" => 0x2C,
#     "Insert"       => 0x2D,
#     "Delete"       => 0x2E,
#     "Help"         => 0x2F,
#     "0"            => 0x30,
#     "1"            => 0x31,
#     "2"            => 0x32,
#     "3"            => 0x33,
#     "4"            => 0x34,
#     "5"            => 0x35,
#     "6"            => 0x36,
#     "7"            => 0x37,
#     "8"            => 0x38,
#     "9"            => 0x39,
#     "A"            => 0x41,
#     "B"            => 0x42,
#     "C"            => 0x43,
#     "D"            => 0x44,
#     "E"            => 0x45,
#     "F"            => 0x46,
#     "G"            => 0x47,
#     "H"            => 0x48,
#     "I"            => 0x49,
#     "J"            => 0x4A,
#     "K"            => 0x4B,
#     "L"            => 0x4C,
#     "M"            => 0x4D,
#     "N"            => 0x4E,
#     "O"            => 0x4F,
#     "P"            => 0x50,
#     "Q"            => 0x51,
#     "R"            => 0x52,
#     "S"            => 0x53,
#     "T"            => 0x54,
#     "U"            => 0x55,
#     "V"            => 0x56,
#     "W"            => 0x57,
#     "X"            => 0x58,
#     "Y"            => 0x59,
#     "Z"            => 0x5A,
#     # Windows keys
#     "Numpad 0"     => 0x60,
#     "Numpad 1"     => 0x61,
#     "Numpad 2"     => 0x62,
#     "Numpad 3"     => 0x63,
#     "Numpad 4"     => 0x64,
#     "Numpad 5"     => 0x65,
#     "Numpad 6"     => 0x66,
#     "Numpad 7"     => 0x67,
#     "Numpad 8"     => 0x68,
#     "Numpad 9"     => 0x69,
#     "Multiply"     => 0x6A,
#     "Add"          => 0x6B,
#     "Separator"    => 0x6C,
#     "Subtract"     => 0x6D,
#     "Decimal"      => 0x6E,
#     "Divide"       => 0x6F,
#     "F1"           => 0x70,
#     "F2"           => 0x71,
#     "F3"           => 0x72,
#     "F4"           => 0x73,
#     "F5"           => 0x74,
#     "F6"           => 0x75,
#     "F7"           => 0x76,
#     "F8"           => 0x77,
#     "F9"           => 0x78,
#     "F10"          => 0x79,
#     "F11"          => 0x7A,
#     "F12"          => 0x7B,
#     "F13"          => 0x7C,
#     "F14"          => 0x7D,
#     "F15"          => 0x7E,
#     "F16"          => 0x7F,
#     "F17"          => 0x80,
#     "F18"          => 0x81,
#     "F19"          => 0x82,
#     "F20"          => 0x83,
#     "F21"          => 0x84,
#     "F22"          => 0x85,
#     "F23"          => 0x86,
#     "F24"          => 0x87,
#     "Num Lock"     => 0x90,
#     "Scroll Lock"  => 0x91,
#     # Multiple position Shift, Ctrl and Menu keys
#     ";:"           => 0xBA,
#     "+"            => 0xBB,
#     ","            => 0xBC,
#     "-"            => 0xBD,
#     "."            => 0xBE,
#     "/?"           => 0xBF,
#     "`~"           => 0xC0,
#     "{"            => 0xDB,
#     "\|"           => 0xDC,
#     "}"            => 0xDD,
#     "'\""          => 0xDE,
#     "AX"           => 0xE1 # Japan only
#   }
#
#   # Available buttons at gamepad.
#   GAMEPAD_LIST = {
#     "Button A"       => 0x00,
#     "Button B"       => 0x01,
#     "Button X"       => 0x02,
#     "Button Y"       => 0x03,
#     "Button Back"    => 0x04,
#     "Button Guide"   => 0x05,
#     "Button Start"   => 0x06,
#     "Left Stick"     => 0x07,
#     "Right Stick"    => 0x08,
#     "Left Shoulder"  => 0x09,
#     "Right Shoulder" => 0x0A,
#     "D-Pad Up"       => 0x0B,
#     "D-Pad Down"     => 0x0C,
#     "D-Pad Left"     => 0x0D,
#     "D-Pad Right"    => 0x0E,
#     # The below ones are commented since they aren't working
#     # properly in my last test.
#     #   "Button Misc"    => 0x0F, # Xbox Series X share button, PS5 microphone button, Nintendo Switch Pro capture button, Amazon Luna microphone button
#     #   "Paddle 1"       => 0x10, # Xbox Elite paddle P1 (upper left, facing the back)
#     #   "Paddle 2"       => 0x11, # Xbox Elite paddle P3 (upper right, facing the back)
#     #   "Paddle 3"       => 0x12, # Xbox Elite paddle P2 (lower left, facing the back)
#     #   "Paddle 4"       => 0x13, # Xbox Elite paddle P4 (lower right, facing the back)
#     #   "Touchpad"       => 0x14, # PS4/PS5 touchpad button
#   }
#
#   # Available axis at gamepad.
#   # This one is manually checked
#   GAMEPAD_AXIS_LIST = {
#     "L-Stick Left"   => Input::LEFT_STICK_LEFT,
#     "L-Stick Right"  => Input::LEFT_STICK_RIGHT,
#     "L-Stick Up"     => Input::LEFT_STICK_UP,
#     "L-Stick Down"   => Input::LEFT_STICK_DOWN,
#     "RStick Left"   => Input::RIGHT_STICK_LEFT,
#     "RStick Right"  => Input::RIGHT_STICK_RIGHT,
#     "RStick Up"     => Input::RIGHT_STICK_UP,
#     "RStick Down"   => Input::RIGHT_STICK_DOWN,
#     "Left Trigger"  => Input::LEFT_TRIGGER,
#     "Right Trigger" => Input::RIGHT_TRIGGER,
#   }
#
#   def self.key_name(key_code)
#     ret = KEYBOARD_LIST.key(key_code)
#     return ret if ret
#     ret = GAMEPAD_LIST.key(key_code - Input::GAMEPAD_OFFSET)
#     return ret if ret
#     ret = GAMEPAD_AXIS_LIST.key(key_code - Input::AXIS_OFFSET)
#     return ret if ret
#     return key_code==0 ? "None" : "?"
#   end
#
#   def self.key_code(key_name)
#     ret  = KEYBOARD_LIST[key_name]
#     if !ret && GAMEPAD_LIST.has_key?(key_name)
#       ret  = GAMEPAD_LIST[key_name] + Input::GAMEPAD_OFFSET
#     end
#     if !ret && GAMEPAD_AXIS_LIST.has_key?(key_name)
#       ret  = GAMEPAD_AXIS_LIST[key_name] + Input::AXIS_OFFSET
#     end
#     raise "The key #{key_name} no longer exists! " if !ret
#     return ret
#   end
#
#   def self.detect_key
#     loop do
#       Graphics.update
#       Input.update
#       for key_code in KEYBOARD_LIST.values
#         next if !Input.triggerex?(key_code)
#         return key_code
#       end
#       if Input.const_defined?(:Controller)
#         for original_code in GAMEPAD_LIST.values
#           next if !Input::Controller.triggerex?(original_code)
#           return original_code + Input::GAMEPAD_OFFSET
#         end
#         for original_code in GAMEPAD_AXIS_LIST.values
#           next if !Input.axis_triggerex?(original_code)
#           return original_code + Input::AXIS_OFFSET
#         end
#       end
#     end
#   end
# end if SetControls::ENABLED
#
# # Existing class stored in saves.
# class PokemonSystem
#   attr_writer :game_controls
#   def game_controls
#     @game_controls = Keys.default_controls if !@game_controls
#     return @game_controls
#   end
#
#   def game_control_code(control_action)
#     ret = []
#     for control in game_controls
#       ret.push(control.key_code) if control.control_action == control_action
#     end
#     return ret
#   end
# end
#
# module SetControls
#   def self.open_ui(menu_to_refresh=nil)
#     scene=Scene.new
#     screen=Screen.new(scene)
#     pbFadeOutIn {
#       screen.start_screen
#       menu_to_refresh.pbRefresh if menu_to_refresh
#     }
#   end
#
#   # Returns an array with all keys who does the action.
#   def self.key_array(action)
#     return $PokemonSystem.game_controls.find_all{|c|
#       c.control_action==action
#     }.map{|c| c.key_name}
#   end
#
#   # Actions handler. It has an array with all actions.
#   # Workaround to work with older script version saves in Window_Controls
#   class ActionHandler
#     def [](index)
#       return @data_array[index]
#     end
#
#     def size
#       return @data_array.size
#     end
#
#     def initialize(controls)
#       @data_array = create_data_array(
#         Keys.default_controls.map{|c| c.control_action}.uniq,
#         create_controls_per_action(controls)
#       )
#     end
#
#     def create_controls_per_action(controls)
#       ret = {}
#       for control in controls
#         ret[control.control_action] ||= []
#         ret[control.control_action].push(control)
#       end
#       return ret
#     end
#
#     def create_data_array(action_array, controls_per_action)
#       return action_array.map{|a| ActionData.new(a,controls_per_action[a])}
#     end
#
#     def create_save_control_array
#       return @data_array.map{|action_data| action_data.control_array}.flatten
#     end
#
#     def clear_keys_with_input(input)
#       for index in 0...size
#         key_index = 0
#         while key_index < self[index].size
#           if self[index].control_array[key_index].key_code==input
#             if self[index].size > 1
#               self[index].delete_key_at(key_index)
#               key_index-=1
#             else
#               self[index].control_array[key_index].key_code = 0
#             end
#           end
#           key_index+=1
#         end
#       end
#     end
#
#     def set_key(new_input, action_index, key_index)
#       if key_index >= self[action_index].size
#         self[action_index].add_key(new_input)
#       else
#         self[action_index].control_array[key_index].key_code = new_input
#       end
#       self[action_index].sort_keys! if SetControls::AUTO_SORT
#     end
#   end
#
#   # Has an action, with all of his keys and controls
#   class ActionData
#     attr_reader :name
#     attr_reader :control_array
#
#     def initialize(name, control_array)
#       @name = name
#       @control_array = control_array || []
#       sort_keys! if SetControls::AUTO_SORT
#     end
#
#     def size
#       return @control_array.size
#     end
#
#     def has_any_key?
#       return size>1 || (size!=0 && @control_array[0].key_code!=0)
#     end
#
#     def key_code_equals?(index, key_code)
#       return size > index && @control_array[index].key_code == key_code
#     end
#
#     # All keys text, like "C, B"
#     def keys_text
#       return key_array.join(", ")
#     end
#
#     def key_array
#       return @control_array.map{|control| _INTL(control.key_name)}
#     end
#
#     # The value also need to be added in main array
#     # Return new added value
#     def add_key(new_input)
#       @control_array.push(ControlConfig.new_by_code(@name, new_input))
#       return @control_array[-1]
#     end
#
#     # The value also need to be removed from main array
#     def delete_key_at(index)
#       @control_array.delete_at(index)
#     end
#
#     def sort_keys!
#       return if size <= 1
#       sorted_keys = @control_array.map{|c|c.key_code}.sort
#       for i in 0...size
#         @control_array[i].key_code = sorted_keys[i]
#       end
#     end
#   end
#
#   class Window_Controls < Window_DrawableCommand
#     attr_reader :reading_input
#     attr_reader :changed
#
#     DEFAULT_EXTRA_INDEX = 0
#     EXIT_SAVE_INDEX = 1
#     EXIT_EXTRA_INDEX = 2
#
#     def initialize(controls,x,y,width,height)
#       @action_handler = ActionHandler.new(controls)
#       @name_base_color   = Color.new(88,88,80)
#       @name_shadow_color = Color.new(168,184,184)
#       @sel_base_color    = Color.new(24,112,216)
#       @sel_shadow_color  = Color.new(136,168,208)
#       @reading_key_index = nil
#       @changed = false
#       super(x,y,width,height)
#     end
#
#     def itemCount
#       return @action_handler.size+EXIT_EXTRA_INDEX+1
#     end
#
#     def controls
#       return @action_handler.create_save_control_array
#     end
#
#     def reading_input?
#       return @reading_key_index != nil
#     end
#
#     def set_new_input(new_input)
#       if @action_handler[@index].key_code_equals?(@reading_key_index, new_input)
#         @reading_key_index = nil
#         return
#       end
#       @action_handler.clear_keys_with_input(new_input)
#       @action_handler.set_key(new_input, @index, @reading_key_index)
#       @reading_key_index = nil
#       @changed = true
#       refresh
#     end
#
#     def on_exit_index?
#       return @action_handler.size + EXIT_EXTRA_INDEX == @index
#     end
#
#     def on_save_exit_index?
#       return @action_handler.size + EXIT_SAVE_INDEX == @index
#     end
#
#     def on_default_index?
#       return @action_handler.size + DEFAULT_EXTRA_INDEX == @index
#     end
#
#     def item_description
#       ret=nil
#       if on_save_exit_index?
#         ret=_INTL("Save your changes and exit.")
#       elsif on_exit_index?
#         ret=_INTL("Exit without saving your changes.")
#       elsif on_default_index?
#         ret=_INTL("Restore the default controls.")
#       else
#         ret= control_description(@action_handler[@index].name)
#       end
#       return ret
#     end
#     def control_description(control_action)
#       hash = {}
#       hash["Down"        ] = _INTL("Moves the character. Select entries and navigate menus.")
#       hash["Left"        ] = hash["Down"]
#       hash["Right"       ] = hash["Down"]
#       hash["Up"          ] = hash["Down"]
#       hash["Action"      ] = _INTL("Confirm a choice, check things, talk to people, and move through text.")
#       hash["Cancel"      ] = _INTL("Exit, cancel a choice or mode, and move at field in a different speed.")
#       hash["Menu"        ] = _INTL("Open the menu. Also has various functions depending on context.")
#       hash["Scroll Up"   ] = _INTL("Advance quickly in menus.")
#       hash["Scroll Down" ] = hash[ "Scroll Up"]
#       hash["Ready Menu"  ] = _INTL("Open Ready Menu, with registered items and available field moves.")
#       hash["Speed Up"     ] = _INTL("Toggles fast-forward speed.")
#       return hash.fetch(control_action, _INTL("Set the controls."))
#     end
#
#     def drawItem(index,_count,rect)
#       rect=drawCursor(index,rect)
#       name = case index - @action_handler.size
#              when DEFAULT_EXTRA_INDEX   ; _INTL("Default")
#              when EXIT_SAVE_INDEX       ; _INTL("Save & Exit")
#              when EXIT_EXTRA_INDEX      ; _INTL("Cancel changes")
#              else                       ; @action_handler[index].name
#              end
#       width= rect.width*6/20
#       pbDrawShadowText(
#         self.contents,rect.x,rect.y-4,width,rect.height,
#         name,@name_base_color,@name_shadow_color
#       )
#       self.contents.draw_text(rect.x,rect.y,width,rect.height,name)
#       return if index>=@action_handler.size
#       value = @action_handler[index].keys_text
#       xpos = width+rect.x
#       width = rect.width*14/20
#       pbDrawShadowText(
#         self.contents,xpos,rect.y-4,width,rect.height,
#         value,@sel_base_color,@sel_shadow_color
#       )
#       self.contents.draw_text(xpos,rect.y,width,rect.height,value)
#     end
#
#     def update
#       oldindex=self.index
#       super
#       do_refresh=self.index!=oldindex
#       if self.active && self.index <= @action_handler.size
#         if Input.trigger?(Input::C)
#           if on_default_index?
#             if pbConfirmMessage(_INTL("Are you sure? You can still exit this screen without keeping the changes."))
#               pbPlayDecisionSE()
#               @action_handler = ActionHandler.new(Keys.default_controls)
#               @changed = true
#               do_refresh = true
#             end
#           elsif self.index<@action_handler.size
#             if !@action_handler[index].has_any_key?
#               @reading_key_index = 0 # Replace input
#             else
#               do_refresh ||= open_action_menu
#             end
#           end
#         end
#       end
#       refresh if do_refresh
#     end
#
#     # Return if a refresh is necessary
#     def open_action_menu
#       cmd_add = _INTL("Add key")
#       cmd_replace = _INTL("Replace existing key")
#       cmd_remove = _INTL("Remove key")
#       cmd_cancel = _INTL("Cancel")
#       commands = [cmd_add, cmd_replace, cmd_remove,cmd_cancel]
#       selected = pbMessage(_INTL("What you want to do?"),commands,commands.length)
#       case commands[selected]
#       when cmd_replace # Replace
#         if @action_handler[index].size==1
#           @reading_key_index = 0
#         else
#           @reading_key_index = choose_control_key(
#             self.index, _INTL("Choose an assigned key.")
#           )
#         end
#       when cmd_add # Add
#         if MAX_KEYS_PER_ACTION == @action_handler[index].size
#           pbMessage(_INTL(
#                       "You can't add more than {1} keys to an action!",
#                       MAX_KEYS_PER_ACTION
#                     ))
#         else
#           @reading_key_index = @action_handler[index].size
#         end
#       when cmd_remove # Remove
#         if @action_handler[index].size==1
#           pbMessage(_INTL("You can't remove a key when there was only one!"))
#         else
#           key_index = choose_control_key(
#             self.index, _INTL("Choose an assigned key.")
#           )
#           if key_index
#             @action_handler[index].delete_key_at(key_index)
#             @changed = true
#             return true
#           end
#         end
#       end
#       return false
#     end
#
#     def choose_control_key(index, message)
#       ret = pbMessage(
#         message,
#         @action_handler[index].key_array + [_INTL("Cancel")],
#         @action_handler[index].size + 1
#       )
#       ret = nil if ret==@action_handler[index].size
#       return ret
#     end
#   end
#
#   class Scene
#     def start_scene
#       @sprites={}
#       @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
#       @viewport.z=99999
#       @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
#         _INTL("Controls"),0,0,Graphics.width,64,@viewport
#       )
#       @sprites["textbox"]=pbCreateMessageWindow
#       @sprites["textbox"].letterbyletter=false
#       game_controls = $PokemonSystem.game_controls.map{|c| c.clone}
#       @sprites["controlwindow"]=Window_Controls.new(
#         game_controls,0,@sprites["title"].height,Graphics.width,
#         Graphics.height-@sprites["title"].height-@sprites["textbox"].height
#       )
#       @sprites["controlwindow"].viewport=@viewport
#       @sprites["controlwindow"].visible=true
#       @changed = false
#       pbDeactivateWindows(@sprites)
#       pbFadeInAndShow(@sprites) { update }
#     end
#
#     def update
#       pbUpdateSpriteHash(@sprites)
#     end
#
#     def main
#       pbActivateWindow(@sprites,"controlwindow"){ main_loop}
#     end
#
#     def main_loop
#       last_index=-1
#       loop do
#         Graphics.update
#         Input.update
#         update
#         should_refresh_text = @sprites["controlwindow"].index!=last_index
#         if @sprites["controlwindow"].reading_input?
#           @sprites["textbox"].text=_INTL("Press a new key.")
#           @sprites["controlwindow"].set_new_input(Keys.detect_key)
#           should_refresh_text = true
#           @changed = true
#         elsif Input.trigger?(Input::C) && @sprites["controlwindow"].on_save_exit_index?
#           if @sprites["controlwindow"].controls.find{|c| c.key_code == 0}
#             @sprites["textbox"].text=_INTL("Fill all fields!")
#             should_refresh_text = false
#           else
#             $PokemonSystem.game_controls=@sprites["controlwindow"].controls
#             break
#           end
#         elsif Input.trigger?(Input::B) || (
#           Input.trigger?(Input::C) && @sprites["controlwindow"].on_exit_index?
#         )
#           if @sprites["controlwindow"].changed
#             if pbConfirmMessage(_INTL("Keep changes?"))
#               if @sprites["controlwindow"].controls.find{|c| c.key_code == 0}
#                 @sprites["textbox"].text=_INTL("Fill all fields!")
#                 should_refresh_text = false
#               else
#                 $PokemonSystem.game_controls=@sprites["controlwindow"].controls
#                 break
#               end
#             else
#               break
#             end
#           else
#             break
#           end
#         end
#         if should_refresh_text
#           if(
#             @sprites["textbox"].text!=@sprites["controlwindow"].item_description
#           )
#             @sprites["textbox"].text=@sprites["controlwindow"].item_description
#           end
#           last_index = @sprites["controlwindow"].index
#         end
#       end
#     end
#
#     def end_scene
#       pbPlayCloseMenuSE
#       pbFadeOutAndHide(@sprites) { update }
#       pbDisposeMessageWindow(@sprites["textbox"])
#       pbDisposeSpriteHash(@sprites)
#       @viewport.dispose
#     end
#   end
#
#   class Screen
#     def initialize(scene)
#       @scene=scene
#     end
#
#     def start_screen
#       @scene.start_scene
#       @scene.main
#       @scene.end_scene
#     end
#   end
# end
#
# # MenuHandlers.add(:pause_menu, :controls, {
# #   "name"      => _INTL("Controls"),
# #   "order"     => 75,
# #   "effect"    => proc { |menu|
# #     pbPlayDecisionSE
# #     SetControls.open_ui(menu)
# #     next false
# #   }
# # }) if SetControls::ENABLED