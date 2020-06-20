import "../css/contestant.scss";

import { setup } from "./live_view_boilerplate";
import DrawName from "./hooks/draw_name";
import VibratePhone from "./hooks/vibrate_phone";

const hooks = {
  DrawName: DrawName,
  vibratePhone: VibratePhone,
};
setup(hooks);
