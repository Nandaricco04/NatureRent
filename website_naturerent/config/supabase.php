<?php
const SUPABASE_URL = 'https://anynenrhdtxbkfztmggd.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFueW5lbnJoZHR4YmtmenRtZ2dkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzczMTc4ODcsImV4cCI6MjA5Mjg5Mzg4N30.jfipTTqQ7ghXxkgPKdSNGTxelOMCvL-3Bqh27Qf5xXU';

function supabaseRequest(string $path, string $method = 'GET', ?array $payload = null): array
{
    $url = rtrim(SUPABASE_URL, '/') . '/rest/v1/' . ltrim($path, '/');

    $ch = curl_init($url);
    $headers = [
        'apikey: ' . SUPABASE_ANON_KEY,
        'Authorization: Bearer ' . SUPABASE_ANON_KEY,
        'Content-Type: application/json',
    ];

    if (in_array($method, ['POST', 'PATCH'], true)) {
        $headers[] = 'Prefer: return=representation';
    }

    $options = [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => $headers,
        CURLOPT_CUSTOMREQUEST => $method,
    ];

    if ($payload !== null) {
        $options[CURLOPT_POSTFIELDS] = json_encode($payload);
    }

    curl_setopt_array($ch, $options);

    $response = curl_exec($ch);
    $error = curl_error($ch);
    $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($response === false || $error) {
        return ['ok' => false, 'status' => 0, 'data' => null, 'error' => $error];
    }

    $data = json_decode($response, true);

    return [
        'ok' => $status >= 200 && $status < 300,
        'status' => $status,
        'data' => $data,
        'error' => null,
    ];
}
