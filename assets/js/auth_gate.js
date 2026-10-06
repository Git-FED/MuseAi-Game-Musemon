import {CONFIG} from '../../config.js';
import {supabase,invoke} from './supabase-client.js';import {exportSave} from './save_handler.js';
const $=id=>document.getElementById(id);const status=m=>$('status').textContent=m;
async function run(fn){try{await fn();}catch(e){status(e.message);}}
function enter(save,player){sessionStorage.setItem('fedos_save',JSON.stringify(save));sessionStorage.setItem('fedos_profile',JSON.stringify(player));location.href='game.html';}
$('send').onclick=()=>run(async()=>{const redirect=CONFIG.AUTH_REDIRECT_URL||new URL('index.html',location.href).href;const {error}=await supabase.auth.signInWithOtp({email:$('email').value.trim(),options:{emailRedirectTo:redirect}});if(error)throw error;status('Check your email.');});
function show(s){$('session').hidden=!s;$('send').hidden=!!s;$('identity').textContent=s?.user.email||'';}
supabase.auth.onAuthStateChange((_,s)=>show(s));supabase.auth.getSession().then(({data})=>show(data.session));
$('logout').onclick=()=>run(async()=>{await supabase.auth.signOut();sessionStorage.clear();show(null);});
$('boot').onclick=()=>run(async()=>{const f=$('file').files[0];if(!f)throw Error('Select a save file.');if(f.size>1000000)throw Error('File too large.');const m=(await f.text()).match(/```json\s*([\s\S]*?)```/);if(!m)throw Error('Missing JSON block.');const r=await invoke('verify-save',{payload:JSON.parse(m[1])});enter(r.save,r.player);});
$('checkin').onclick=()=>run(async()=>{const r=await invoke('issue-save',{first_save:true,starting_wing:$('wing').value});await exportSave(r.normalized_payload);enter(r.normalized_payload,r.player);});

$('importCallback').onclick=()=>run(async()=>{const u=new URL($('callback').value.trim());const h=new URLSearchParams(u.hash.slice(1));if(h.get('access_token')&&h.get('refresh_token')){const {error}=await supabase.auth.setSession({access_token:h.get('access_token'),refresh_token:h.get('refresh_token')});if(error)throw error;}else if(u.searchParams.get('code')){const {error}=await supabase.auth.exchangeCodeForSession(u.searchParams.get('code'));if(error)throw error;}else throw Error('URL has no session callback');$('callback').value='';status('Session imported. Keep callback URLs private.');});
