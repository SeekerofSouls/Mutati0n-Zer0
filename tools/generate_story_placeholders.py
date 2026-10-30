#!/usr/bin/env python3
"""Creates v3 story placeholders. Overwrites story/UI assets; use on a copy."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,re,hashlib,csv,textwrap
ROOT=Path(__file__).resolve().parents[1];manifest=json.loads((ROOT/'assets/asset_manifest.json').read_text());src=(ROOT/'scripts/catalog.gd').read_text()
def arr(n):return json.loads(re.search(r'const '+n+r' = (\[.*?\n\])',src,re.S).group(1))
font_path=Path('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf')
def font(size):return ImageFont.truetype(str(font_path),size) if font_path.exists() else ImageFont.load_default()
def color(key):
 h=hashlib.sha256(key.encode()).digest();return tuple(110+x%120 for x in h[:3])+(255,)
def write(key,path,im,purpose):
 dest=ROOT/'assets'/path;dest.parent.mkdir(parents=True,exist_ok=True);im.save(dest)
 manifest[key]={'path':'res://assets/'+path,'width':im.width,'height':im.height,'purpose':purpose}
people=[('character/'+c['id'],c['name']) for c in arr('CHARACTERS')]+[('enemy/'+e['id'],e['name']) for e in arr('ENEMIES')]+[('boss/'+b['kind'],b['name']) for b in arr('BOSSES')]+[('ai','LABOR-KI')]
for key,name in people:
 for emotion in ['neutral','happy','angry','hurt']:
  im=Image.new('RGBA',(96,96));d=ImageDraw.Draw(im);c=color(key)
  if key=='ai':
   d.rectangle((12,12,84,82),fill=(25,40,53,255),outline=(116,245,204,255),width=4)
   d.line((29,42,38,42),fill='white',width=5);d.line((58,42,67,42),fill='white',width=5)
  else:
   d.ellipse((14,8,82,86),fill=c,outline=(32,40,55,255),width=3)
   for x in [34,62]:d.ellipse((x-6,34,x+6,47),fill=(12,20,32,255))
  if emotion=='happy':d.arc((28,48,69,77),0,180,fill=(240,245,255,255),width=5)
  elif emotion=='angry':
   d.line((25,28,41,35),fill=(12,20,32,255),width=5);d.line((55,35,71,28),fill=(12,20,32,255),width=5);d.line((31,66,66,66),fill='white',width=3)
  elif emotion=='hurt':
   d.line((27,37,41,46),fill='white',width=4);d.line((57,46,70,37),fill='white',width=4);d.ellipse((40,59,58,73),outline='white',width=3)
  else:d.line((33,65,64,65),fill=(240,245,255,255),width=3)
  write('portrait/'+key+'/'+emotion,'portraits/'+key+'/'+emotion+'.png',im,name+' Kopfporträt: '+{'neutral':'neutral','happy':'begeistert','angry':'ernst / wütend','hurt':'verletzt'}[emotion])
frame=Image.new('RGBA',(640,128),(0,0,0,245));d=ImageDraw.Draw(frame);d.rectangle((2,2,637,125),outline=(245,245,250,255),width=4)
write('ui/dialogue_box','ui/dialogue_box.png',frame,'Sprechkasten: wird auf 740 × 130 px skaliert; Text bleibt getrennt')
frame=Image.new('RGBA',(112,112),(0,0,0,255));ImageDraw.Draw(frame).rectangle((2,2,109,109),outline=(245,245,250,255),width=3)
write('ui/portrait_frame','ui/portrait_frame.png',frame,'Rahmen um das 96 × 96 px Kopfporträt')
intro=json.loads((ROOT/'assets/dialogue/intro_de.json').read_text())['panels']
for index,p in enumerate(intro):
 im=Image.new('RGBA',(960,480),(15,22,32,255));d=ImageDraw.Draw(im)
 d.text((32,22),'PLATZHALTER '+str(index+1)+' / '+p['title'],font=font(24),fill=(130,150,175))
 for x in range(0,960,80):d.line((x,80,x,480),fill=(25,34,46),width=1)
 if index==0:
  for x in [230,480,730]:d.rounded_rectangle((x-60,120,x+60,350),radius=30,fill=(25,57,67),outline=(116,245,204),width=4)
 elif index==1:
  d.rounded_rectangle((360,95,600,390),radius=36,outline=(116,245,204),width=5);d.ellipse((420,170,540,300),fill=(130,140,235));d.text((355,402),'UNBRAUCHBAR. ENTSORGEN.',font=font(20),fill=(238,120,150))
 elif index==2:
  d.rectangle((250,280,760,420),fill=(47,39,48),outline=(110,90,110),width=4)
  for x in [320,430,580,670]:d.ellipse((x,320,x+40,350),fill=(100,110,130))
  d.ellipse((430,230,510,310),fill=(130,140,235));d.line((500,110,470,210),fill=(220,190,125),width=8)
 elif index==3:
  d.ellipse((385,170,565,370),fill=(130,140,235));d.line((535,300,690,240),fill=(116,245,204),width=28)
  for off in range(6):d.line((690,240,740+off*12,150+off*28),fill=(116,245,204),width=3)
 elif index==4:
  d.rectangle((570,110,690,410),outline=(238,120,150),width=8);d.ellipse((340,240,430,350),fill=(130,140,235));d.line((410,270,600,210),fill=(116,245,204),width=22);d.text((365,110),'ALARM',font=font(42),fill=(238,120,150))
 else:
  d.rectangle((370,100,620,425),fill=(6,9,15),outline=(116,245,204),width=8);d.ellipse((250,280,330,385),fill=(130,140,235));d.line((300,370,350,390),fill=(130,140,235),width=15)
 write('cutscene/'+p['id'],'cutscene/'+p['id']+'.png',im,'Anfangssequenz Bild '+str(index+1)+': '+p['title'])
for biome in arr('BIOMES'):
 for event in arr('EVENTS'):
  im=Image.new('RGBA',(920,584));d=ImageDraw.Draw(im);d.text((270,40),event['name'],font=font(22),fill=color(biome['id']))
  d.ellipse((360,205,560,405),outline=color(biome['id']),width=3)
  write('biome/'+biome['id']+'/'+event['id'],'rooms/'+biome['id']+'/'+event['id']+'_overlay.png',im,biome['name']+' Sonderraum: '+event['name'])
for event in arr('EVENTS'):
 im=Image.new('RGBA',(32,32));d=ImageDraw.Draw(im);d.rectangle((4,4,28,28),fill=color(event['id']),outline='white',width=2);d.text((10,10),'?',font=font(14),fill=(0,0,0))
 write('prop/event_'+event['id'],'props/event_'+event['id']+'.png',im,'Interaktionsobjekt: '+event['name'])
# Reference mockup uses only our own placeholder assets. Not a game screenshot.
preview=Image.new('RGBA',(840,180),(18,25,38,255));preview.alpha_composite(Image.open(ROOT/'assets/ui/dialogue_box.png').resize((820,150)),(10,15));preview.alpha_composite(Image.open(ROOT/'assets/portraits/character/null/happy.png'),(28,42));d=ImageDraw.Draw(preview);d.text((146,34),'NULL',font=font(18),fill=(116,245,204))
line='Ey Alter, wie geil ist das denn? Jetzt kann ich drei von den Viechern gleichzeitig wegfetzen!'
for n,text in enumerate(textwrap.wrap(line,width=52)):d.text((146,67+n*26),text,font=font(20),fill=(240,245,250))
preview.save(ROOT/'art_templates/DIALOG_BEISPIEL.png')
(ROOT/'assets/asset_manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2))
with (ROOT/'ASSET_LIST.csv').open('w',newline='',encoding='utf-8-sig') as f:
 w=csv.writer(f,delimiter=';');w.writerow(['Key','Datei','Breite px','Höhe px','Zellenmaß','Spalten','Zeilen','Verwendung'])
 for key,v in manifest.items():w.writerow([key,v['path'][6:],v['width'],v['height'],v.get('cell',''),v.get('columns',1),v.get('rows',1),v['purpose']])
print('Visual entries:',len(manifest),'including',len(people)*4,'portraits and six cutscene panels')
