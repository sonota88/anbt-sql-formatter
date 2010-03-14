// 次の 3つのパスをお使いの環境に合わせて書き換えてください。

// ruby.exe の場所
var envPath = "C:\\ruby\\bin\\ruby.exe";

// サクラエディタのマクロを置いているフォルダ
var macroDir = "C:\\apps\\sakuraW_rXXXX\\macros\\";

// anbt-sql-formatter のフォルダ
var asfHome = "C:\\apps\\anbt-sql-formatter\\";


//================================


function checkPath( path ){
  if( ! path.match( /\\$/ ) ){
    path += "\\";
  }
  
  return path;
}

macroDir = checkPath( macroDir );
asfHome  = checkPath( asfHome );


//================================


var scriptPath   = asfHome + "bin\\anbt-sql-formatter";
var libDir       = asfHome + "lib";

var macroPath    = macroDir + "anbt-sql-formatter-for-sakura-editor.js";
var tempFileSrc  = macroDir + "____temp_src.txt";
var tempFileDest = macroDir + "____temp_dest.txt";

var timeoutSec   = 10;


//================================


var ForReading = 1;
var ForWriting = 2;

var wShell = new ActiveXObject( "WScript.Shell" );


//================================


function pathExists( varName, type ){
  var path = eval(varName);
  var fso = new ActiveXObject( "Scripting.FileSystemObject" );
  var typeMsg;
  var result = true;

  switch(type){
  case "file":
    typeMsg = "ファイル";
    if( ! fso.FileExists( path ) ){
      result = false;
    }
    break;
  case "folder":
    typeMsg = "フォルダ";
    if( ! fso.FolderExists( path ) ){
      result = false;
    }
    break;
  default:
    wShell.Popup( "変数 type の指定が間違っています。" );
    return;
  }

  if( ! result ){
    wShell.Popup( typeMsg + ' "' + path + "\" が見つかりません。\n変数 " + varName + " のパス指定を確認してください。" );
    return false;
  }else{
    return true;
  }
}


//================================


function writeFile( path, content ){
  var fso = new ActiveXObject( "Scripting.FileSystemObject" );
  var fout = fso.CreateTextFile( path );
  fout.WriteLine( content );
  fout.Close();
}


function readFile( path ){
  var fso = new ActiveXObject( "Scripting.FileSystemObject" ); 
  var fout = fso.OpenTextFile( path, ForReading ); 
  var content = fout.ReadAll();
  fout.Close(); 
  return content;
}


//================================


function callFromSakuraEditor(){
  if(    ! pathExists( "envPath" , "file" )
      || ! pathExists( "macroDir", "folder" )
      || ! pathExists( "asfHome" , "folder" )
  ){
    return;
  }

  var selectedStr = GetSelectedString(0);
  var fso = new ActiveXObject( "Scripting.FileSystemObject" );
  if( fso.FileExists( tempFileSrc  ) ){ fso.GetFile( tempFileSrc  ).Delete(); }
  if( fso.FileExists( tempFileDest ) ){ fso.GetFile( tempFileDest ).Delete(); }

  writeFile( tempFileSrc, selectedStr );

  var commandStr = 'cscript "' + macroPath + '"';
  var vbHide = 0; //ウィンドウを非表示
  wShell.Run( commandStr, vbHide, true );

  insText( readFile( tempFileDest ) );

  if( fso.FileExists( tempFileSrc  ) ){ fso.GetFile( tempFileSrc  ).Delete(); }
  if( fso.FileExists( tempFileDest ) ){ fso.GetFile( tempFileDest ).Delete(); }
}


function callFromCScript(){
  var commandStr = 'cmd /c  ' + envPath + ' -I ' + libDir + ' "' + scriptPath +'"  "'+ tempFileSrc + '"' ;
  var execObj = wShell.Exec( commandStr );

  // 処理が終了するか、またはタイムアウトするまで待つ
  var startSec = (new Date()).getTime();
  while( execObj.status == 0){
    WScript.Sleep( 500 );
    if( (new Date()).getTime() - startSec > timeoutSec ){ break; }
  }

  var result;
  if( execObj.exitCode == 0){
    result = execObj.StdOut.ReadAll();
  }else{
    result = execObj.StdErr.ReadAll();
  }
  writeFile( tempFileDest, result );
}


//================================


if( typeof(Editor) != "undefined" ){
  callFromSakuraEditor();
}else if( typeof(WScript) != "undefined" ){
  callFromCScript();
}else{
  wShell.Popup( "呼び出し元がわかりません。" );
}
