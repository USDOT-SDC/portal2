package org.apache.guacamole.auth.header.user;

import com.nimbusds.jose.JOSEException;
import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.jwk.source.JWKSource;
import com.nimbusds.jose.jwk.source.RemoteJWKSet;
import com.nimbusds.jose.proc.BadJOSEException;
import com.nimbusds.jose.proc.JWSKeySelector;
import com.nimbusds.jose.proc.JWSVerificationKeySelector;
import com.nimbusds.jose.proc.SecurityContext;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.proc.BadJWTException;
import com.nimbusds.jwt.proc.DefaultJWTProcessor;
import java.net.MalformedURLException;
import java.net.URL;
import java.text.ParseException;

public class AuthenticationUtil {
	public static JWTClaimsSet validateAWSJwtToken(String token, String webKeyUrl) {
		try {
			DefaultJWTProcessor defaultJWTProcessor = new DefaultJWTProcessor();
			JWKSource<SecurityContext> jwkSource = null;
			RemoteJWKSet remoteJWKSet = new RemoteJWKSet(new URL(webKeyUrl));
			JWSAlgorithm jwsAlgorithm = JWSAlgorithm.RS256;
			JWSVerificationKeySelector jWSVerificationKeySelector = new JWSVerificationKeySelector(jwsAlgorithm, (JWKSource) remoteJWKSet);
			defaultJWTProcessor.setJWSKeySelector((JWSKeySelector) jWSVerificationKeySelector);
			JWTClaimsSet claimsSet = defaultJWTProcessor.process(token, null);
			return claimsSet;
		} catch (BadJWTException e) {
			e.printStackTrace();
		} catch (ParseException e) {
			e.printStackTrace();
		} catch (JOSEException e) {
			e.printStackTrace();
		} catch (BadJOSEException e) {
			e.printStackTrace();
		} catch (MalformedURLException e) {
			e.printStackTrace();
		}
		return null;
	}
}
