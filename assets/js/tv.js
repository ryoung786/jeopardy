// We need to import the CSS so that webpack will load it.
// The  MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/tv.scss";
import { setup } from "./live_view_boilerplate";
import Stats from "./hooks/stats";
import FinalJeopardyReveal from "./hooks/final_jeopardy_reveal";

setup({
  stats: Stats,
  FinalJeopardyReveal: FinalJeopardyReveal,
});
