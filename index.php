<?php
include('vendor/autoload.php');

use Symfony\Component\HttpFoundation\Request;

$trustedHeaderSet = Request::HEADER_X_FORWARDED_FOR
    | Request::HEADER_X_FORWARDED_HOST
    | Request::HEADER_X_FORWARDED_PORT
    | Request::HEADER_X_FORWARDED_PROTO
    | Request::HEADER_X_FORWARDED_AWS_ELB
    | Request::HEADER_X_FORWARDED_TRAEFIK;

Request::setTrustedProxies([$_SERVER['REMOTE_ADDR']], $trustedHeaderSet);
$request = Request::createFromGlobals();

$data = [
    'hostname' => gethostname(),
    'url' => $request->getSchemeAndHttpHost() . $request->getRequestUri(),
    'host' => $request->getHost(),
    'schema' => $request->getScheme(),
    'clientIp' => $request->getClientIp(),
    'clientIps' => implode(', ', $request->getClientIps()),
    'remoteAddr' => $request->server->get('REMOTE_ADDR'),
    'server' => $request->server->get('SERVER_ADDR') . ':' . $request->server->get('SERVER_PORT'),
    'xHeaders' => array_filter($_SERVER, fn($key) => str_starts_with($key, 'HTTP_X_'), ARRAY_FILTER_USE_KEY),
];

header('Content-Type: application/json; charset=utf-8');
echo json_encode($data);

?>
