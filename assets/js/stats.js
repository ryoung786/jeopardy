// We need to import the CSS so that webpack will load it.
// The  MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/stats.scss";
import { setup } from "./live_view_boilerplate";
import Stats from "./hooks/stats";

const hooks = { stats: Stats };
setup(hooks);
