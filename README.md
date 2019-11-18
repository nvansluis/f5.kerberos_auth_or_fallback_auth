# f5.kerberos_auth_or_fallback_auth
F5 APM Kerberos Auth or fallback to another authentication method

## APM Access Policy
The screenshot below shows an example of an Access Policy that uses either Kerberos or SAML authentication.

![alt text](https://www.van-sluis.nl/f5/images/kerberos_auth_or_fallback_auth/Kerberos-AP.png)

The first agent in the policy is an 'Empty Agent' which will read the session.custom.domainjoined variable to determine which authentication method to use. The session.custom.domainjoined variable is set by the kerberos_auth_or_fallback_auth iRule.

![alt text](https://www.van-sluis.nl/f5/images/kerberos_auth_or_fallback_auth/Kerberos-Empty-Action.png)
