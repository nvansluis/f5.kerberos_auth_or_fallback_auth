# iRule: f5.kerberos_auth_or_fallback_auth

when RULE_INIT {
    set static::webworker_task {

self.addEventListener('message', function(e) {
  
  fetch(e.data, function(xhr) {	
		var status = xhr.status;
		self.postMessage(status);
  });

}, false);


	//simple XHR request in pure raw JavaScript
	function fetch(url, callback) {
		var xhr;
		
		//console.log(url);

		if(typeof XMLHttpRequest !== 'undefined') xhr = new XMLHttpRequest();
		else {
			var versions = ["MSXML2.XmlHttp.5.0", 
			 				"MSXML2.XmlHttp.4.0",
			 			    "MSXML2.XmlHttp.3.0", 
			 			    "MSXML2.XmlHttp.2.0",
			 				"Microsoft.XmlHttp"]

			 for(var i = 0, len = versions.length; i < len; i++) {
			 	try {
			 		xhr = new ActiveXObject(versions[i]);
			 		break;
			 	}
			 	catch(e){}
			 } // end for
		}
		
		xhr.onreadystatechange = ensureReadiness;
		
		function ensureReadiness() {
			if(xhr.readyState < 4) {
				return;
			}
			
			if(xhr.status !== 200) {
				return;
			}

			// all is well	
			if(xhr.readyState === 4) {
				callback(xhr);
			}			
		}
		xhr.open('GET', url, true);
		xhr.send('');
	}
}

    set static::html_start { <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<meta charset="utf-8">
<title></title>
</head>
<body>
<script>
}

    set static::html_end {
var evtFired = false;
setTimeout(function() {
    if (!evtFired) {
      url += ( url.match( /[\?]/g ) ? '&' : '?' ) + 'domainjoined=false';
      window.location.replace(url);
    }
}, 500);

var worker = new Worker('worker.js');

worker.addEventListener('message', function(e) {
  evtFired = true;
  url += ( url.match( /[\?]/g ) ? '&' : '?' ) + 'domainjoined=true';
  window.location.replace(url);
}, false);

worker.postMessage('/kerberos/test/'); // Send filename to our worker.
</script>
</body>
</html>
}
}

when HTTP_REQUEST {
    set request [HTTP::uri]
    set first_request 0
    set domainjoined 0

    if { [HTTP::cookie exists "DOMAINJOINED"] } {
        ACCESS::enable
        if { [HTTP::cookie "DOMAINJOINED"] == 1 } {
            set domainjoined 1
        }
        return
    }
   
    set cur_time [clock seconds]
    set cur_time [expr $cur_time + 180]
    set formated_time [clock format $cur_time -format "%a, %d %h %Y %T %Z" -gmt true]
          
    set domainjoined [URI::query [HTTP::uri] domainjoined]
   
    switch $domainjoined {
       "false" {
            ACCESS::enable
            #set first_request 0
            HTTP::uri [string map {"?domainjoined=false" ""} [HTTP::uri]]
            HTTP::uri [string map {"&domainjoined=false" ""} [HTTP::uri]]
            HTTP::respond 302 Location [HTTP::uri] Set-Cookie "DOMAINJOINED=0;expires=$formated_time;path=/;secure"
            return
        }
        "true" {
            ACCESS::disable
            #set first_request 0
            HTTP::uri [string map {"?domainjoined=true" ""} [HTTP::uri]]
            HTTP::uri [string map {"&domainjoined=true" ""} [HTTP::uri]]
            HTTP::respond 302 Location [HTTP::uri] Set-Cookie "DOMAINJOINED=1;expires=$formated_time;path=/;secure"
            return
        }
        default {
            ACCESS::disable
        }
   }

    switch [HTTP::uri] {
        "/worker.js" {
            HTTP::respond 200 content $static::webworker_task
            return
        }
        "/kerberos/test/" {
             if { [HTTP::header exists "Authorization"] } {
                 HTTP::respond 200 content "OK"
                 return
             }
             else {
                 HTTP::respond 401 "WWW-Authenticate" "Negotiate"
                 return
             }
        }
    }
    
    set first_request 1
    if { ( [HTTP::cookie exists MRHSession] ) and ( [ACCESS::session exists -state_allow [HTTP::cookie value MRHSession]] ) } {
        ACCESS::enable
        set first_request 0
    }
}

when HTTP_RESPONSE {
    if { ( $first_request == 1 ) } {
        set content "$static::html_start var url = '$request'; $static::html_end"
        HTTP::respond 200 content $content
    }
}

when ACCESS_SESSION_STARTED {
    ACCESS::session data set session.custom.domainjoined $domainjoined
}
