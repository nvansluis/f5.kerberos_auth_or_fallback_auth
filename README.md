# F5 APM Kerberos Auth or fallback to another authentication method

This iRule can be used when it is required to offer both Kerberos authentication and for example SAML or another authentication method in a mixed environment for devices that are domain joined and devices that are not domain joined. This iRule uses javascript and HTML5 Web Workers to determine if the browser can successfully authenticate by using Kerberos or will need to fallback to another authentication method.

I've been testing this iRule with Internet Explorer, Edge, Firefox and Chrome. All these browsers seem to be working fine. Only Chrome seems to do things a bit differently and is showing a login prompt for a split second, but it's working.

## APM Access Policy
The screenshot below shows an example of an Access Policy that uses either Kerberos or SAML authentication.

![alt text](https://www.van-sluis.nl/f5/images/kerberos_auth_or_fallback_auth/Kerberos-AP.png)

The first agent in the policy is an 'Empty Agent' which will read the session.custom.domainjoined variable to determine which authentication method to use. The session.custom.domainjoined variable is set by the kerberos_auth_or_fallback_auth iRule.

![alt text](https://www.van-sluis.nl/f5/images/kerberos_auth_or_fallback_auth/Kerberos-Empty-Action.png)

