import "../css/contestant.scss";

import { setup } from "./live_view_boilerplate";
import DrawName from "./hooks/draw_name";
import VibratePhone from "./hooks/vibrate_phone";
import EarlyBuzzPenalty from "./hooks/early_buzz_penalty";
import SomeoneElseBuzzedIn from "./hooks/someone_else_buzzed_in";

const hooks = {
  DrawName: DrawName,
  vibratePhone: VibratePhone,
  EarlyBuzzPenalty: EarlyBuzzPenalty,
  SomeoneElseBuzzedIn: SomeoneElseBuzzedIn,
};
setup(hooks);
