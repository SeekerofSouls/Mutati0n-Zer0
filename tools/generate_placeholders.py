#!/usr/bin/env python3
"""Recreates PLACEHOLDERS. Warning: overwrites painted assets. Run on a copy only."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import re,json,math,hashlib,csv,wave,struct
ROOT=Path(__file__).resolve().parents[1]
CAT=(ROOT/'scripts/catalog.gd').read_text()
def array(n):return json.loads(re.search(r'const '+n+r' = (\[.*?\n\])',CAT,re.S).group(1))
manifest={}
font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',12) if Path('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf').exists() else ImageFont.load_default()
small=ImageFont.load_default()
states=['idle','walk','shoot','hurt','dash','death'];dirs=['down','left','right','up']
def color(id):
 h=hashlib.sha256(id.encode()).digest();return (110+h[0]%120,110+h[1]%120,110+h[2]%120,255)
def write(key,path,im,purpose,**meta):
 dest=ROOT/'assets'/path;dest.parent.mkdir(parents=True,exist_ok=True);im.save(dest)
 manifest[key]=dict(path='res://assets/'+path,width=im.width,height=im.height,purpose=purpose,**meta)
def sheet(key,path,label,cell=48,headless=False,overlay=False):
 im=Image.new('RGBA',(cell*6,cell*24));d=ImageDraw.Draw(im);c=color(key)
 for st,state in enumerate(states):
  for di,dir in enumerate(dirs):
   for f in range(6):
    cx=f*cell+cell//2;cy=(st*4+di)*cell+int(cell*.56)
    bob=(f%3-1)*max(1,cell//32) if state in ['walk','idle'] else 0
    cy+=bob
    if overlay:
     category=int(hashlib.sha256(key.encode()).hexdigest()[:4],16)%4
     if category==0:d.ellipse((cx-cell*.36,cy-cell*.5,cx+cell*.36,cy+cell*.17),outline=c,width=max(1,cell//24))
     elif category==1:d.polygon([(cx-cell*.3,cy-cell*.4),(cx-cell*.45,cy-cell*.7),(cx-cell*.05,cy-cell*.45)],fill=c)
     elif category==2:d.line((cx-cell*.25,cy,cx+cell*.3,cy-cell*.2),fill=c,width=max(1,cell//16))
     else:d.ellipse((cx+cell*.2,cy-cell*.35,cx+cell*.4,cy-cell*.15),fill=c)
     continue
    if state=='death':
     r=cell*.28*(1-f*.12);d.ellipse((cx-r,cy-r/2,cx+r,cy+r/2),fill=(*c[:3],max(30,255-f*35)));continue
    swing=math.sin(f*math.pi/3)*cell*.10 if state=='walk' else 0
    # Feet stay within a fixed frame; all characters share the same anchor.
    for sign in [-1,1]:
     fx=cx+sign*cell*.12;fy=cy+cell*.22+sign*swing
     d.ellipse((fx-cell*.08,fy-cell*.06,fx+cell*.08,fy+cell*.08),fill=c)
    d.ellipse((cx-cell*.26,cy-cell*.15,cx+cell*.26,cy+cell*.22),fill=c,outline=(32,40,55,255),width=max(1,cell//24))
    if not headless:
     d.ellipse((cx-cell*.23,cy-cell*.49,cx+cell*.23,cy-cell*.04),fill=c,outline=(32,40,55,255),width=max(1,cell//24))
     offset={'down':(0,2),'up':(0,-3),'left':(-3,0),'right':(3,0)}[dir]
     for sign in [-1,1]:
      ex=cx+sign*cell*.08+offset[0];ey=cy-cell*.29+offset[1]
      d.ellipse((ex-2,ey-2,ex+2,ey+2),fill=(12,20,32,255))
    else:
     d.ellipse((cx-3,cy-cell*.18,cx+3,cy-cell*.08),fill=(235,64,100,255))
    if state=='shoot':d.ellipse((cx+cell*.22,cy-cell*.12,cx+cell*.40,cy+cell*.03),fill=(245,225,120,255))
    if state=='hurt':d.rectangle((cx-cell*.15,cy-cell*.08,cx+cell*.15,cy+cell*.06),fill=(255,255,255,200))
    if state=='dash':d.line((cx-cell*.45,cy,cx-cell*.25,cy),fill=c,width=3)
 write(key,path,im,label,cell=cell,columns=6,rows=24,states=states,directions=dirs,anchor='center')
for c in array('CHARACTERS'):sheet('character/'+c['id'],'characters/'+c['id']+'.png','Charakter '+c['name'])
for e in array('ENEMIES'):sheet('enemy/'+e['id'],'enemies/'+e['id']+'.png',e['name']+': '+e['desc'])
sheet('enemy/decapitator_headless','enemies/decapitator_headless.png','Blutläufer ohne Kopf',headless=True)
for b in array('BOSSES'):sheet('boss/'+b['kind'],'bosses/'+b['kind']+'.png','Boss '+b['name'],96)
for item in array('ITEMS'):
 id=item['id'];im=Image.new('RGBA',(32,32));d=ImageDraw.Draw(im);c=color(id)
 d.regular_polygon((16,16,12),3+int(hashlib.sha256(id.encode()).hexdigest()[:2],16)%4,fill=(*c[:3],100),outline=c)
 d.text((10,10),id[:2].upper(),font=small,fill=c)
 write('item/'+id,'items/'+id+'.png',im,item['name']+': '+item['desc'])
 sheet('mutation/'+id,'mutations/'+id+'.png','Optionaler Charakter-Layer: '+item['name'],overlay=True)
for b in array('BIOMES'):
 id=b['id'];c=tuple(int(b['color'][i:i+2],16) for i in (0,2,4))
 tile=Image.new('RGBA',(64,64),tuple(int(v*.11) for v in c)+(255,));d=ImageDraw.Draw(tile);d.rectangle((1,1,62,62),outline=tuple(int(v*.24) for v in c)+(255,));d.line((0,32,64,32),fill=(*c,18))
 write('biome/'+id+'/floor','rooms/'+id+'/floor_tile.png',tile,b['name']+' wiederholbare Bodenfliese')
 bg=Image.new('RGBA',(920,584));d=ImageDraw.Draw(bg)
 for x,y in [(18,18),(902,18),(18,566),(902,566)]:d.rectangle((x-4,y-4,x+4,y+4),fill=(*c,255))
 write('biome/'+id+'/background','rooms/'+id+'/room_background.png',bg,b['name']+' Raumhintergrund über Bodenfliesen')
 for typ in ['start','combat','treasure','shop','rest','boss','transition']:
  overlay=Image.new('RGBA',(920,584));d=ImageDraw.Draw(overlay)
  d.text((350,36),b['name']+' / '+typ.upper(),font=font,fill=(*c,140))
  if typ=='transition':
   d.ellipse((310,182,610,402),outline=(*c,100),width=4);d.line((460,400,460,560),fill=(*c,150),width=4)
  write('biome/'+id+'/'+typ,'rooms/'+id+'/'+typ+'_overlay.png',overlay,b['name']+' '+typ+' Raum-Dekoration')
 rock=Image.new('RGBA',(64,64));d=ImageDraw.Draw(rock);d.regular_polygon((32,32,26),6,fill=tuple(int(v*.28) for v in c)+(255,),outline=(*c,255))
 write('biome/'+id+'/rock','rooms/'+id+'/rock.png',rock,b['name']+' zerstörbarer Felsen')
 for state in ['open','closed']:
  im=Image.new('RGBA',(64,96));d=ImageDraw.Draw(im);d.rectangle((4,4,60,92),fill=(12,20,32,255),outline=(*c,255),width=4)
  if state=='closed':d.line((8,8,56,88),fill=(*c,255),width=4);d.line((56,8,8,88),fill=(*c,255),width=4)
  else:d.rectangle((24,8,40,88),fill=(*c,80))
  write('biome/'+id+'/door_'+state,'rooms/'+id+'/door_'+state+'.png',im,b['name']+' Tür '+state+'; horizontal um 90 Grad drehen')
  write('biome/'+id+'/door_'+state+'_horizontal','rooms/'+id+'/door_'+state+'_horizontal.png',im.transpose(Image.Transpose.ROTATE_90),b['name']+' horizontale Tür '+state)
for id in ['player_shot','enemy_shot','blood_shot','coin','heal','bomb','portal','drone','orbiter','shield','rock_debris','detached_head']:
 im=Image.new('RGBA',(32,32));d=ImageDraw.Draw(im);c=(235,64,100,255) if 'blood' in id else color(id)
 d.ellipse((5,5,27,27),fill=c,outline=(240,240,245,255),width=1)
 if id=='heal':d.line((16,9,16,23),fill=(255,255,255),width=3);d.line((9,16,23,16),fill=(255,255,255),width=3)
 write('prop/'+id,'props/'+id+'.png',im,'Objekt: '+id)
for id in ['explosion','blood_splash','blood_puddle','acid_pool','teleport','spawn','impact','muzzle']:
 im=Image.new('RGBA',(256,32));d=ImageDraw.Draw(im);c=color(id)
 if 'blood' in id:c=(235,64,100,255)
 for f in range(8):
  r=3+f*1.5;cx=f*32+16
  d.ellipse((cx-r,16-r*.65,cx+r,16+r*.65),outline=(*c[:3],255-f*22),width=2)
 write('fx/'+id,'effects/'+id+'.png',im,'Effektanimation '+id,cell=32,columns=8,rows=1,fps=12)
# Blank templates and numbered guides. Guides include margins and are NOT runtime assets.
templates=ROOT/'art_templates';templates.mkdir(exist_ok=True)
for name,cell in [('character_enemy_48',48),('boss_96',96)]:
 Image.new('RGBA',(cell*6,cell*24)).save(templates/(name+'_blank.png'))
 guide=Image.new('RGB',(cell*6+180,cell*24+50),(20,28,42));d=ImageDraw.Draw(guide)
 d.text((10,8),name+' | 6 columns x 24 rows',font=font,fill='white')
 for row in range(24):
  y=50+row*cell;d.text((8,y+cell//2-7),states[row//4]+' / '+dirs[row%4],font=font,fill=(160,180,210))
  for f in range(6):
   x=180+f*cell;d.rectangle((x,y,x+cell-1,y+cell-1),outline=(80,100,120));d.text((x+3,y+3),str(f),font=font,fill=(115,150,170))
   d.line((x+cell//2-4,y+cell//2,x+cell//2+4,y+cell//2),fill=(115,150,170))
 guide.save(templates/(name+'_guide.png'))
Image.new('RGBA',(32,32)).save(templates/'item_icon_32_blank.png')
Image.new('RGBA',(256,32)).save(templates/'effect_8x32_blank.png')
(ROOT/'assets/asset_manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2))
with (ROOT/'ASSET_LIST.csv').open('w',newline='',encoding='utf-8-sig') as f:
 w=csv.writer(f,delimiter=';');w.writerow(['Key','Datei','Breite px','Höhe px','Zellenmaß','Spalten','Zeilen','Verwendung'])
 for key,v in manifest.items():w.writerow([key,v['path'][6:],v['width'],v['height'],v.get('cell',''),v.get('columns',1),v.get('rows',1),v['purpose']])
# Customizable audio placeholders: real, valid WAV files. Music loops are eight seconds.
audio=ROOT/'assets/audio';audio.mkdir(exist_ok=True)
sound_ids=['shoot','hit','pickup','hurt','dash','boom','unlock','door','head_pop','blood_spray','enemy_shoot','boss_roar','boss_defeat','teleport','coin','death','win','step']
for i,id in enumerate(sound_ids):
 duration=.12 if id in ['shoot','step','coin'] else .35
 with wave.open(str(audio/(id+'.wav')),'wb') as w:
  w.setnchannels(1);w.setsampwidth(2);w.setframerate(22050)
  w.writeframes(b''.join(struct.pack('<h',int(math.sin(2*math.pi*(180+i*35)*n/22050)*6000*(1-n/(22050*duration)))) for n in range(int(22050*duration))))
for i,b in enumerate([{'id':'menu'}]+array('BIOMES')):
 duration=8
 with wave.open(str(audio/('music_'+b['id']+'.wav')),'wb') as w:
  w.setnchannels(1);w.setsampwidth(2);w.setframerate(22050)
  w.writeframes(b''.join(struct.pack('<h',int((math.sin(2*math.pi*(55+i*5)*n/22050)+.4*math.sin(2*math.pi*(110+i*10)*n/22050))*2000)) for n in range(22050*duration)))
config={'pitch_randomness':.04,'music_volume':.35,'effects':{id:{'path':'res://assets/audio/'+id+'.wav','volume':.22 if id=='shoot' else .65} for id in sound_ids},'music':{b['id']:{'path':'res://assets/audio/music_'+b['id']+'.wav','volume':1.0} for b in [{'id':'menu'}]+array('BIOMES')}}
config['effects']['step']['volume']=.08
config['effects']['blood_spray']['volume']=.18
config['effects']['enemy_shoot']['volume']=.25
(ROOT/'assets/audio/audio_config.json').write_text(json.dumps(config,indent=2))
print('Created',len(manifest),'visual assets;',len(sound_ids),'sound effects; 6 music loops')
