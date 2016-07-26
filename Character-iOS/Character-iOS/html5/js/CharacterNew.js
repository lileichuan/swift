function Character(option) {
    /*
     @containerId canvas的存放id
     @content: 字体的轮廓
     @canvasId: canvas的id
     @size: canvas宽高大小
     @fontColor: 笔画播放字体填充颜色
     @blkColor: 默认字体填充颜色
     @frameMode: 背景模式0无背景 1田字格 2米字格 其它非法
     @imageName: 背景图片名称，如果有此属性，则首先背景图片，其次应用frameMode
     @backgroundColor: 背景颜色
     @borderColor: 边框和及内部田/米字格线条颜色
     @borderWidth: 边框和及内部田/米字格线条宽度
     @lineWidth: 文字线条宽度
     @radicalsColor:部首颜色
     * */
    this.option = {
    containerId: 'container',
    content: null,
    attribute: {
    canvasId: 'cs1',
    size: 480,
    fontColor: 'lightgray',
    blkColor: '#FF0000',
    frameMode: 0,
    imageName: '',
    backgroundColor: '#eaeff1',
    borderColor: '#6e95B3',
    borderWidth: 1,
    lineWidth: 76,
    radicalsColor:'lightgray'
    }
    };
    
    this.step = 4;
    this.Ri = 0;
    this.Ti = 0;
    this.CurStep = 1;
    this.timer = null;
    this.from = 0;
    this.to = 0;
    this.subMode = false;
    this.radicals_begin = 0;
    this.radicals_end = 0;
    this.phonogram_begin = 0;
    this.phonogram_end = 0;
    this.symbol_begin = 0;
    this.symbol_end = 0;
    this.stepMode = false;
    this.beComplete = false;
    this.radicalsArr = null;
    this.symbolArr = null;
    this.phonogramArr = null;
    
    //初始化参数
    //对content进行合并
    var o = JSON.parse(option.content[0]);
    for (var i = 1, l = option.content.length; i < l; i++) {
        o = $.extend(true, o, JSON.parse(option.content[i]));
    }
    
    var optionCopy = $.extend(true, {}, option);
    optionCopy.content = o;
    
    if (optionCopy.content.attribute) {
        if (optionCopy.content.attribute.radicalsArr) {
        		this.radicalsArr = optionCopy.content.attribute.radicalsArr;
        }
        if(optionCopy.content.attribute.radicals){
        	 this.radicals_begin = optionCopy.content.attribute.radicals.begin;
       		 this.radicals_end = optionCopy.content.attribute.radicals.end;
        }
        if (optionCopy.content.attribute.symbolArr) {
             this.symbolArr = optionCopy.content.attribute.symbolArr;

        }
        if(optionCopy.content.attribute.symbol){
        	this.symbol_begin = optionCopy.content.attribute.symbol.begin;
            this.symbol_end = optionCopy.content.attribute.symbol.end;
        }

        if (optionCopy.content.attribute.phonogramArr) {
            this.phonogramArr = optionCopy.content.attribute.phonogramArr;
        }
        if(optionCopy.content.attribute.phonogram){
        	this.phonogram_begin = optionCopy.content.attribute.phonogram.begin;
            this.phonogram_end = optionCopy.content.attribute.phonogram.end;
        }
        	
    };
    
    this.option = $.extend(true, this.option, optionCopy);
}
/*
 */
//  var oldArrayIndexOf = Array.indexOf;
//  Array.prototype.indexOf = function(obj) {
//     if(!oldArrayIndexOf) {
//         for(var i = 0, imax = this.length; i < imax; i++) {
//             if(this[i] === obj) {
//                 return i;
//             }
//         }
//         return-1;
//     } else{
//         return oldArrayIndexOf(obj);
//     }
// }

Character.prototype = {
constructor: Character,

/*******************************************************************
  功能:初始化
  参数:option
 ******************************************************************/
init: function(option) {
    //指定canvasId是否存在
    var that = this,
    oCanvas = document.getElementById(that.option.attribute.canvasId),
    size = that.option.attribute.size;
    
    //页面中是否已经存在指定的canvas
    if (oCanvas && oCanvas.getContext) {
        oCanvas.getContext('2d').clearRect(0, 0, size, size);
    } else {
        //设置canvas样式
        $('#' + that.option.containerId).append('<div id="main"><canvas id="' + that.option.attribute.canvasId + '" width="' + size + '" height="' + size + '" style="cursor:default;">您的浏览器不支持canvas!</canvas></div><div id="strokes"></div>');
    }
    
    //开始画布设置
    oCanvas = document.getElementById(that.option.attribute.canvasId);
    var ctx = oCanvas.getContext('2d');
    ctx.fillStyle = that.option.attribute.backgroundColor;
    ctx.strokeStyle = that.option.attribute.borderColor;
    ctx.lineWidth = that.option.attribute.borderWidth;
    
    //画背景
    if (that.option.attribute.imageName) {
        var oImg = new Image();
        oImg.src = that.option.attribute.imageName;
        oImg.onload = function() {
            ctx.drawImage(oImg, 0, 0, size, size);
            _drawFrame();
        };
    } else {
        switch (that.option.attribute.frameMode) {
            case 0:
                //空
                break;
            case 1:
                //田字格
                _drawSpecialBg(1);
                break;
            case 2:
                //米字格
                _drawSpecialBg(2)
                break;
            default:
                throw new Error('错误的背景参数！');
        }
        
        _drawFrame();
    }
    
    //绑定点击事件
    $(oCanvas).off('.canvas').on('click.canvas', function(e) {
                                 if (that.beComplete) {
                                 return;
                                 }
                                 
                                 that.playCharacter();
                                 return false;
                                 });
    
    //画“十”和“米”
    function _drawSpecialBg(bgType) {
        //bgType:1十字  2 米字
        ctx.save();
        
        //画边框，根据that.option.attribute.borderWidth确认上下文位置
        //边框在起始位置在一个边框宽度的中间，矩形大小为画布大小减去1个边框的大小
        var halfBorder = Math.ceil(that.option.attribute.borderWidth / 2),
        size1 = size - halfBorder * 2;
        
        //如果有背景色则填充背景色，然后描边
        ctx.fillRect(halfBorder, halfBorder, size1, size1);
        ctx.strokeRect(halfBorder, halfBorder, size1, size1);
        
        //后绘置于先绘下面
        ctx.globalCompositionOperation = 'destination-over';
        
        //画十字
        size = that.option.attribute.size;
        
        var halfSize = size / 2;
        ctx.beginPath();
        
        //竖线
        ctx.moveTo(halfSize, 0);
        ctx.lineTo(halfSize, size);
        
        //横线
        ctx.moveTo(0, halfSize);
        ctx.lineTo(size, halfSize);
        
        //画交叉斜线
        if (bgType == 2) {
            ctx.moveTo(0, 0);
            ctx.lineTo(size, size);
            
            ctx.moveTo(size, 0);
            ctx.lineTo(0, size);
        }
        
        ctx.stroke();
        ctx.restore();
    }
    
    //画字
    function _drawFrame() {
        ctx.save();
        
        var fontSize = that.option.content.size,
        blkColor = that.option.attribute.blkColor;
        
        //缩放图像
        ctx.scale(size / fontSize, size / fontSize);
        
        ctx.strokeStyle = blkColor;
        ctx.fillStyle = blkColor;
        ctx.lineWidth = 0;
        
        ctx.beginPath();
        
        for (var i = 0, l = that.option.content.points.length; i < l; i++) {
            var p = that.option.content.points[i];
            
            for (var j = 0; j < p.R.length; j++) {
                if (p.R[j].t == 0) {
                    ctx.moveTo(p.R[j].x, p.R[j].y);
                } else if (p.R[j].t == 1) {
                    ctx.lineTo(p.R[j].x, p.R[j].y);
                } else {
                    ctx.bezierCurveTo(p.R[j].cx1, p.R[j].cy1, p.R[j].cx2, p.R[j].cy2, p.R[j].x, p.R[j].y);
                }
            }
        }
        
        ctx.fill();
        ctx.stroke();
        ctx.closePath();
        ctx.restore();
    }
},


triggerStep:function(){
    $(document).trigger('stepbegin', 11);
},

/*******************************************************************
  功能:笔画播放
  参数:无
 ******************************************************************/
playCharacter: function() {
    var self = this,
    oCanvas = document.getElementById(self.option.attribute.canvasId),
    size = self.option.attribute.size,
    fontSize = self.option.content.size;
    if (oCanvas.getContext) {
        var ctx = oCanvas.getContext('2d');
        
        clearInterval(self.timer);
        self.timer = setInterval(function() {
                                 if (self.Ti == 0 && self.CurStep == 1 && self.Ri != self.option.content.points.length) {
                                     $(document).trigger('stepbegin', self.Ri+1);
                                 };
                                 
                                 if (self.Ri < self.from - 1) {
                                 self.Ri += 1;
                                 self.CurStep = 1;
                                 return;
                                 };
                                 
                                 if (self.Ri == self.option.content.points.length) {
                                 self.Ri = 0;
                                 self.Ti = 0;
                                 self.CurStep = 1;
                                 self.beComplete = true;
                                 clearInterval(self.timer);
                                 return;
                                 }
                                 
                                 if (self.Ti == self.option.content.points[self.Ri].T.length - 1) {
                                 self.Ri += 1;
                                 self.Ti = 0;
                                 self.CurStep = 1;
                                 
                                 if ((self.subMode && self.Ri == self.to) || self.stepMode) {
                                 clearInterval(self.timer);
                                 }
                                 
                                 if (self.Ri == self.option.content.points.length) {
                                  $(document).trigger("complete");
                            
                                 } else {
                                 $(document).trigger("stepend", self.Ri);
                                 }
                                 
                                 return;
                                 }
                                 
                                 ctx.save();
                                 ctx.scale(size / fontSize, size / fontSize);
                                 
                                 var p = self.option.content.points[self.Ri];
                                 ctx.beginPath();
                                 
                                 for (var j = 0; j < p.R.length; j++) {
                                 if (p.R[j].t == 0) {
                                 ctx.moveTo(p.R[j].x, p.R[j].y);
                                 } else if (p.R[j].t == 1) {
                                 ctx.lineTo(p.R[j].x, p.R[j].y);
                                 } else {
                                 ctx.bezierCurveTo(p.R[j].cx1, p.R[j].cy1, p.R[j].cx2, p.R[j].cy2, p.R[j].x, p.R[j].y);
                                 }
                                 }
                                 ctx.closePath();
                                 
                                 //创建一个剪辑
                                 ctx.clip();
                                 
                                 var nTi = self.Ti + 1;
                                 var l = Math.sqrt((parseInt(p.T[self.Ti].x) - parseInt(p.T[nTi].x)) * (parseInt(p.T[self.Ti].x) - parseInt(p.T[nTi].x)) + (parseInt(p.T[self.Ti].y) - parseInt(p.T[nTi].y)) * (parseInt(p.T[self.Ti].y) - parseInt(p.T[nTi].y)));
                
                                 var pc = Math.floor(l / self.step);
                                 var xStep = (parseInt(p.T[nTi].x) - parseInt(p.T[self.Ti].x)) / pc;
                                 var yStep = (parseInt(p.T[nTi].y) - parseInt(p.T[self.Ti].y)) / pc;
                                 var nextPt = {
                                 x: parseInt(p.T[self.Ti].x) + self.CurStep * xStep,
                                 y: parseInt(p.T[self.Ti].y) + self.CurStep * yStep
                                 };
                                 if (self.phonogramArr) {
                                    if (self.phonogramArr.indexOf(self.Ri + 1) != -1) {
                                        ctx.strokeStyle = self.option.attribute.radicalsColor;
                                       
                                    }
                                    else{
                                         ctx.strokeStyle = self.option.attribute.fontColor;
                                    }

                                 }
                                 else{
                                     if (self.Ri + 1 >= self.radicals_begin && self.Ri + 1<= self.radicals_end) {
                                        ctx.strokeStyle = self.option.attribute.radicalsColor;
                                    }
                                     else{
                                        ctx.strokeStyle = self.option.attribute.fontColor;
                                     }
                                 }
                                 
            
                  
                                 ctx.lineWidth = self.option.attribute.lineWidth;
                                 
                                 //控制线条末端的为圆头
                                 ctx.lineCap = "round";
                                 
                                 //控制线条相交的方式为圆交
                                 ctx.lineJoin = "round";
                                 
                                 ctx.beginPath();
                                 ctx.moveTo(parseInt(p.T[self.Ti].x), parseInt(p.T[self.Ti].y));
                                 ctx.lineTo(parseInt(nextPt.x), parseInt(nextPt.y));
                                 ctx.stroke();
                                 
                                 self.CurStep += 1;
                                 if (self.CurStep > pc) {
                                 self.Ti += 1;
                                 self.CurStep = 1;
                                 }
                                 ctx.restore();
                                 }, 10);
    }
},

/*******************************************************************
  功能:显示笔画播放顺序
  参数:option
 ******************************************************************/
createSplit: function(option) {
    var that = this,
    optionDefault = {
				containerId: 'strokes',
				content: null,
				attribute: {
                canvasId: 'cs',
                size: 70,
                fontColor: 'lightgray',
                blkColor: '#FF0000',
                frameMode: 2,
                imageName: null,
                backgroundColor: '#eaeff1',
                borderColor: '#6e95B3',
                borderWidth: 1
                }
    };
    
    //合并数据源
    var o = JSON.parse(option.content[0]);
    for (var i = 1, l = option.content.length; i < l; i++) {
        o = $.extend(true, o, JSON.parse(option.content[i]));
    }
    
    option.content = o;
    option = $.extend(true, optionDefault, option);
    
    //清空原来数据
    $('#strokes').empty();
    
    for (var i = 0, l = option.content.points.length; i < l; i++) {
        
        //创建每一笔的小画布
        var subCanvasId = option.attribute.canvasId + i;
        
        $('#' + option.containerId).append('<canvas id="' + subCanvasId + '" width="' + option.attribute.size + '" height="' + option.attribute.size + '" style="cursor:default;">您的浏览器不支持canvas!</canvas>');
        
        var oCanvas = document.getElementById(subCanvasId),
        h = [];
        
        for (var j = 0; j < i + 1; j++) {
            h.push(option.content.points[j]);
        };
        
        var character = {
            "unicode": that.option.content.characters,
            "size": that.option.content.size,
            "points": h
        };
        
        //画每个小画布
        if (oCanvas.getContext) {
            var ctx = oCanvas.getContext('2d'),
            attrs = option.attribute,
            size = option.attribute.size;
            
            ctx.clearRect(0, 0, attrs.size, attrs.size);
            ctx.fillStyle = option.attribute.backgroundColor;
            ctx.strokeStyle = option.attribute.borderColor;
            ctx.lineWidth = option.attribute.borderWidth;
            
            ctx.save();
            
            if (attrs.backgroundColor) {
                ctx.fillStyle = attrs.backgroundColor;
                ctx.fillRect(0, 0, attrs.size, attrs.size);
            };
            
            ctx.restore();
            
            //画背景
            if (option.attribute.imageName) {
                var oImg = new Image();
                oImg.src = option.attribute.imageName;
                oImg.onload = (function(ctx, character) {
                               return function() {
                               ctx.drawImage(oImg, 0, 0, size, size);
                               _drawFrame(ctx, character);
                               }
                               })(ctx, character);
                
            } else {
                switch (option.attribute.frameMode) {
                    case 0:
                        //空
                        break;
                    case 1:
                        //田字格
                        _drawSpecialBg(1);
                        break;
                    case 2:
                        //米字格
                        _drawSpecialBg(2)
                        break;
                    default:
                        throw new Error('错误的背景参数！');
                }
                
                _drawFrame(ctx, character);
            }
            
            //画“十”和“米”
            function _drawSpecialBg(bgType) {
                //bgType:1十字  2 米字
                ctx.save();
                
                //画边框，根据that.option.attribute.borderWidth确认上下文位置
                //边框在起始位置在一个边框宽度的中间，矩形大小为画布大小减去1个边框的大小
                var halfBorder = Math.ceil(option.attribute.borderWidth / 2),
                size1 = size - halfBorder * 2;
                
                //如果有背景色则填充背景色，然后描边
                ctx.fillRect(halfBorder, halfBorder, size1, size1);
                ctx.strokeRect(halfBorder, halfBorder, size1, size1);
                
                //画十字
                size = option.attribute.size;
                
                var halfSize = size / 2;
                ctx.beginPath();
                
                //竖线
                ctx.moveTo(halfSize, 0);
                ctx.lineTo(halfSize, size);
                
                //横线
                ctx.moveTo(0, halfSize);
                ctx.lineTo(size, halfSize);
                
                //画交叉斜线
                if (bgType == 2) {
                    ctx.moveTo(0, 0);
                    ctx.lineTo(size, size);
                    
                    ctx.moveTo(size, 0);
                    ctx.lineTo(0, size);
                }
                
                ctx.stroke();
                ctx.restore();
            }
            
            //画字
            function _drawFrame(ctx, character) {
                alert('drawframe');
                ctx.save();
                
                var fontSize = option.content.size,
                blkColor = option.attribute.blkColor;
                
                //缩放图像
                ctx.scale(size / fontSize, size / fontSize);
                
                ctx.strokeStyle = blkColor;
                ctx.fillStyle = blkColor;
                ctx.lineWidth = 5;
                
                ctx.beginPath();
                
                for (var i = 0, l = character.points.length; i < l; i++) {
                    var p = option.content.points[i];
                    
                    for (var j = 0; j < p.R.length; j++) {
                        if (p.R[j].t == 0) {
                            ctx.moveTo(p.R[j].x, p.R[j].y);
                        } else if (p.R[j].t == 1) {
                            ctx.lineTo(p.R[j].x, p.R[j].y);
                        } else {
                            ctx.bezierCurveTo(p.R[j].cx1, p.R[j].cy1, p.R[j].cx2, p.R[j].cy2, p.R[j].x, p.R[j].y);
                        }
                    }
                }
                
                ctx.fill();
                ctx.stroke();
                ctx.closePath();
                ctx.restore();
            }
        }
    };
},

/*******************************************************************
  功能:设置笔画播放方式
  参数:
     mode = 0 顺序完全自动播放 
     mode = 1 部分播放：
                type=0 按部首播放
                type = 1 表示按照声符播放
                type = 2 表示按照义符播放
     mode = 2 一笔一画播放   
 ******************************************************************/
setPlayMode: function(mode, type) {
    var self = this;
    if (mode == 0) {
        self.subMode = false;
        self.stepMode = false;
    } else if (mode == 1) {
        self.subMode = true;
        self.stepMode = false;
        if (type == 0) {
            self.from = self.radicals_begin;
            self.to = self.radicals_end;
        } else if (type == 1) {
            self.from = self.phonogram_begin;
            self.to = self.phonogram_end;
        } else if (type == 2) {
            self.from = self.symbol_begin;
            self.to = self.symbol_end;
        };
    } else if (mode == 2) {
        self.subMode = false;
        self.stepMode = true;
    };
}
}
