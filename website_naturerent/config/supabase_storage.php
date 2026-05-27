<?php
require_once __DIR__ . '/supabase.php';

function supabaseStorageUpload(string $bucket, string $objectPath, string $filePath, string $mimeType): array
{
    $url = rtrim(SUPABASE_URL, '/') . '/storage/v1/object/' . rawurlencode($bucket) . '/' . str_replace('%2F', '/', rawurlencode($objectPath));
    $fileContent = file_get_contents($filePath);

    if ($fileContent === false) {
        return ['ok' => false, 'status' => 0, 'data' => null, 'error' => 'File gagal dibaca.'];
    }

    $ch = curl_init($url);
    $headers = [
        'apikey: ' . SUPABASE_ANON_KEY,
        'Authorization: Bearer ' . SUPABASE_ANON_KEY,
        'Content-Type: ' . $mimeType,
        'x-upsert: false',
    ];

    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => $headers,
        CURLOPT_CUSTOMREQUEST => 'POST',
        CURLOPT_POSTFIELDS => $fileContent,
    ]);

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
        'error' => $data['message'] ?? null,
        'publicUrl' => rtrim(SUPABASE_URL, '/') . '/storage/v1/object/public/' . rawurlencode($bucket) . '/' . str_replace('%2F', '/', rawurlencode($objectPath)),
    ];
}

function supabaseStorageDelete(string $bucket, string $objectPath): array
{
    $url = rtrim(SUPABASE_URL, '/') . '/storage/v1/object/' . rawurlencode($bucket);

    $ch = curl_init($url);
    $headers = [
        'apikey: ' . SUPABASE_ANON_KEY,
        'Authorization: Bearer ' . SUPABASE_ANON_KEY,
        'Content-Type: application/json',
    ];

    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => $headers,
        CURLOPT_CUSTOMREQUEST => 'DELETE',
        CURLOPT_POSTFIELDS => json_encode(['prefixes' => [$objectPath]]),
    ]);

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
        'error' => $data['message'] ?? null,
    ];
}
