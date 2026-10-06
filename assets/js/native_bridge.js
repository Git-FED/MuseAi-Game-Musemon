import {Capacitor} from '@capacitor/core';
import {Filesystem,Directory,Encoding} from '@capacitor/filesystem';
import {Share} from '@capacitor/share';
export async function saveFile(name,content){
if(Capacitor.isNativePlatform()){const r=await Filesystem.writeFile({path:name,data:content,directory:Directory.Cache,encoding:Encoding.UTF8});await Share.share({title:name,url:r.uri});return;}
if(window.__TAURI_INTERNALS__){const {save}=await import('@tauri-apps/plugin-dialog');const {writeTextFile}=await import('@tauri-apps/plugin-fs');const path=await save({defaultPath:name,filters:[{name:'Markdown',extensions:['md']}]});if(path)await writeTextFile(path,content);return;}
const url=URL.createObjectURL(new Blob([content],{type:'text/markdown'}));const a=document.createElement('a');a.href=url;a.download=name;a.click();setTimeout(()=>URL.revokeObjectURL(url),10000);}
window.saveFile=saveFile;
