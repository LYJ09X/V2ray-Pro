if ($response.statusCode != 200) {
  $done(null);
}

const emojis= ['๐','๐ฒ','โ ๏ธ','๐','๐ต','๐ฆ','๐','๐ฅ','๐บ','๐ง','๐ฌ','๐ฆ','๐','โณ๏ธ','๐ด','๐ค','๐ฝ','๐ค','๐', '๐บ', '๐', '๐ถ', '๐ผ','๐', '๐ฅ']
var city0 = "้ซ่ฐญๅธ";
var isp0 = "Cross-GFW.org";
function getRandomInt(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

function City_ValidCheck(para) {
  if(para) {
  return para
  } else
  {
  return city0
//emojis[getRandomInt(emojis.length)]
  }
}

function ISP_ValidCheck(para) {
  if(para) {
  return para
  } else
  {
  return isp0
//emojis[getRandomInt(emojis.length)]
  }
}

function Area_check(para) {
  if(para=="ไธญๅๆฐๅฝ"){
  return "ๅฐๆนพ"
  } else
  {
  return para
  }
}

var body = $response.body;
var obj = JSON.parse(body);
var title = 'ๆตๆฎ้ฑยฐ';//+Area_check(obj['country']);
var subtitle = 'โ็ฑๆ้้ฃ่ตท ้ฃๆญข็ฑ้พๅนณ ๆ้ฃไนๆไฝ โ';
var ip = obj['query'];
var description = 'ๆๅกๅ:'+obj['isp'] + '\n'+'ๅฐๅบ:' +City_ValidCheck(obj['regionName'])+ '\n' + 'IP:'+ obj['query'] + '\n' +'ๆถๅบ:'+ obj['timezone'];
$done({title, subtitle, ip, description});
