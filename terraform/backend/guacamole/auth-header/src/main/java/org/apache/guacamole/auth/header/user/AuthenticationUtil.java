package org.apache.guacamole.auth.header.user;

// SDC CUSTOM — this entire class is custom, not in the upstream extension.
// Validates an AWS Cognito JWT against the user pool's public JWKS endpoint.
//
// Flow:
//   1. Cognito redirects the browser to Guacamole with ?authToken=<JWT>
//   2. AuthenticationProviderService extracts the token from the request
//   3. This class fetches the user pool's public keys from cognito-web-key-url
//      (configured in guacamole.properties) and verifies the JWT signature
//      and claims using the nimbus-jose-jwt library
//   4. On success, returns the JWTClaimsSet so the caller can extract
//      the cognito:username claim; returns null on any validation failure
//
// If cognito-web-key-url is wrong or unreachable, validation will fail and
// users will get "Invalid login" — check guacamole.properties on the server.

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
import java.net.URI;
import java.text.ParseException;
import java.util.logging.Logger;

public class AuthenticationUtil {

    private static final Logger logger = Logger.getLogger(AuthenticationUtil.class.getName());

    public static JWTClaimsSet validateAWSJwtToken(String token, String webKeyUrl) {
        try {
            DefaultJWTProcessor<SecurityContext> jwtProcessor = new DefaultJWTProcessor<>();
            // Fetches Cognito's public signing keys from the JWKS endpoint.
            // RemoteJWKSet caches the keys internally to avoid a round-trip on every request.
            JWKSource<SecurityContext> jwkSource = new RemoteJWKSet<>(URI.create(webKeyUrl).toURL());
            JWSKeySelector<SecurityContext> keySelector =
                    new JWSVerificationKeySelector<>(JWSAlgorithm.RS256, jwkSource);
            jwtProcessor.setJWSKeySelector(keySelector);
            return jwtProcessor.process(token, null);
        } catch (BadJWTException e) {
            logger.warning(() -> "JWT validation failed (bad JWT): " + e.getMessage());
        } catch (ParseException e) {
            logger.warning(() -> "JWT validation failed (parse error): " + e.getMessage());
        } catch (JOSEException e) {
            logger.warning(() -> "JWT validation failed (JOSE error): " + e.getMessage());
        } catch (BadJOSEException e) {
            logger.warning(() -> "JWT validation failed (bad JOSE): " + e.getMessage());
        } catch (IllegalArgumentException | MalformedURLException e) {
            // IllegalArgumentException from URI.create() if the URL is syntactically invalid;
            // MalformedURLException from toURL() if the scheme is unsupported.
            logger.severe(() -> "Cognito web key URL is malformed: " + e.getMessage());
        }
        return null;
    }
}
