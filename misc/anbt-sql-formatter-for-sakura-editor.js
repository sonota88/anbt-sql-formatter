// 次の 3つのパスをお使いの環境に合わせて書き換えてください。

// ruby.exe の場所
var envPath = "C:\\ruby\\bin\\ruby.exe";

// サクラエディタのマクロを置いているフォルダ
var macroDir = "C:\\apps\\sakuraW_rXXXX\\macros\\";

// anbt-sql-formatter のフォルダ
var asfHome = "C:\\apps\\sonota-anbt-sql-formatter-ad9917c\\";

//================================

// このマクロファイルのパス
var macroPath = macroDir + "anbt-sql-formatter-for-sakura-editor.js";

var scriptPath   = asfHome + "bin\\anbt-sql-formatter";
var libDir       = asfHome + "lib";

var tempFileSrc  = macroDir + "____temp.txt";
var tempFileDest = macroDir + "____temp2.txt";

var timeoutSec   = 10;

//================================

var ForReading = 1;
var ForWriting = 2;

var wShell = new ActiveXObject( "WScript.Shell" );

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

if( typeof(Editor) != "undefined" ){
  // ■サクラエディタから呼び出された場合
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

}else if( typeof(WScript)!="undefined" ){
  // ■cscript から呼び出された場合
  var commandStr = 'cmd /c  ' + envPath + ' -I ' + libDir + ' "' + scriptPath +'"  "'+ tempFileSrc + '"' ;
  var execObj = wShell.Exec( commandStr );

  // 処理が終了するか、タイムアウトするまで待つ
  var startSec = (new Date()).getTime();
  while( execObj.status == 0){
    WScript.Sleep( 500 );
    if( (new Date()).getTime() - startSec > timeoutSec ){ break; }
  }

  var result
  if( execObj.exitCode == 0){
    result = execObj.StdOut.ReadAll();
  }else{
    result = execObj.StdErr.ReadAll();
  }
  writeFile( tempFileDest, result );

}else{
  wShell.Popup( "呼び出し元がわかりません。" );
}
