!function(e,t,s,i){var n=null,l=[],a=e(t),o=function(){};e.expr[":"].hasClassStartingWith=function(e,t,s){return new RegExp("\\b"+s[3]).test(e.className)},o.defaults=(o.prototype={globals:{pluginName:"fadeThis",bufferTime:300},defaults:{baseName:"slide-",speed:500,easing:"swing",offset:-40,reverse:!0,distance:50,scrolledIn:null,scrolledOut:null},init:function(e,t){this.addElements(e,t),this._setEvent(),this._checkVisibleElements()},addElements:function(i,n){var l=i===s.body?t:i,a=e(l===t?"body":l),o=this,p=n&&n.baseName?n.baseName:this.defaults.baseName;return a.is(":hasClassStartingWith('"+p+"')")?o._addElement(a,n):a.find(":hasClassStartingWith('"+p+"')").each(function(){o._addElement(e(this),n)}),a},_addElement:function(t,s){var i=t.data("plugin-options"),n={element:t,options:e.extend({},this.defaults,s,i),invp:!1};return l.push(n),this._prepareElement(n),t},_prepareElement:function(e){var t={opacity:0,visibility:"visible",position:"relative"},s=null;if(e.element.hasClass(e.options.baseName+"right"))s="left";else if(e.element.hasClass(e.options.baseName+"left"))s="right";else if(e.element.hasClass(e.options.baseName+"top"))s="bottom";else{if(!e.element.hasClass(e.options.baseName+"bottom"))return!1;s="top"}t[s]=e.options.distance,e.element.css(t)},_setEvent:function(){var e=this;a.on("scroll",function(t){n||(n=setTimeout(function(){e._checkVisibleElements(t),n=null},e.globals.bufferTime))})},_checkVisibleElements:function(t){var s=this;e.each(l,function(e,i){s._isVisible(i)?i.invp||(i.invp=!0,s._triggerFading(i),i.options.scrolledIn&&i.options.scrolledIn.call(i.element,t),i.element.trigger("fadethisscrolledin",t)):i.invp&&(i.invp=!1,i.options.reverse&&s._triggerFading(i,!1),i.options.scrolledOut&&i.options.scrolledOut.call(i.element,t),i.element.trigger("fadethisscrolledout",t))})},_isVisible:function(e){var t=a.scrollTop()+e.options.offset,s=t+a.height()-2*e.options.offset,i=e.element.offset().top,n=i+e.element.height();return n>=t&&i<=s&&n<=s&&i>=t},_triggerFading:function(e,t){t=void 0===t||t;var s={opacity:1},i={opacity:0},n=null;if(e.element.hasClass(e.options.baseName+"right"))n="left";else if(e.element.hasClass(e.options.baseName+"left"))n="right";else if(e.element.hasClass(e.options.baseName+"top"))n="bottom";else{if(!e.element.hasClass(e.options.baseName+"bottom"))return!1;n="top"}s[n]=0,i[n]=e.options.distance,t?e.element.stop(!0).animate(s,e.options.speed,e.options.easing):e.element.stop(!0).animate(i,e.options.speed,e.options.easing)}}).defaults,o.globals=o.prototype.globals,t.Plugin=new o,e.fn[o.globals.pluginName]=function(s){return this.each(function(){e.data(t,"plugin_"+o.globals.pluginName)?e.data(this,"plugin_"+o.globals.pluginName)||e.data(this,"plugin_"+o.globals.pluginName,t.Plugin.addElements(this,s)):(e.data(t,"plugin_"+o.globals.pluginName,"set"),e.data(this,"plugin_"+o.globals.pluginName,t.Plugin.init(this,s)))}),this}}(jQuery,window,document);