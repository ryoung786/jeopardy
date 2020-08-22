import "../css/accounts.scss";
import "./common/header";
import { setup } from "./live_view_boilerplate";
import SaveDraft from "./hooks/save_draft";

setup({
  SaveDraft: SaveDraft,
});
