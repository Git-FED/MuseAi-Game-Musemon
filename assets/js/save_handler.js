import {invoke} from './supabase-client.js';import {saveFile} from './native_bridge.js';
export function markdown(p){return '# FED-OS Memory Token\n\nRevision: '+p.revision_no+'\n\n```json\n'+JSON.stringify(p,null,2)+'\n```\n';}
export async function exportSave(p){await saveFile('muse_save_'+p.email.replace(/[^a-z0-9]/gi,'_')+'.md',markdown(p));}
let busy=false;window.onSaveGame=async()=>{if(busy)return;busy=true;try{const s=window.gameState;const r=await invoke('issue-save',{payload:{stats:{map_id:s.mapId,x_coord:s.x,y_coord:s.y}}});sessionStorage.setItem('fedos_save',JSON.stringify(r.normalized_payload));await exportSave(r.normalized_payload);}catch(e){alert(e.message);}finally{busy=false;}};
