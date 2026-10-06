import {createClient} from '@supabase/supabase-js';
import {CONFIG} from '../../config.js';
export const supabase=createClient(CONFIG.SUPABASE_URL,CONFIG.SUPABASE_PUBLISHABLE);
window.supabase=supabase; window.edgeFn=n=>`${CONFIG.SUPABASE_URL}/functions/v1/${n}`;
export async function invoke(name,body){const {data,error}=await supabase.functions.invoke(name,{body});if(error)throw error;if(!data.ok)throw new Error(data.reason||data.status||data.error);return data;}
