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

function findUserByEmail(string $email): ?array
{
    $query = http_build_query([
        'select' => 'id_user,nama,email,password,role',
        'email' => 'eq.' . strtolower(trim($email)),
        'limit' => '1',
    ]);

    $result = supabaseRequest('users?' . $query);

    if (!$result['ok'] || empty($result['data'])) {
        return null;
    }

    return $result['data'][0];
}

function getUsersByRole(string $role): array
{
    $query = http_build_query([
        'select' => '*',
        'role' => 'eq.' . $role,
        'order' => 'id_user.asc',
    ]);

    $result = supabaseRequest('users?' . $query);

    if (!$result['ok'] || !is_array($result['data'])) {
        return [];
    }

    return $result['data'];
}

function findUserById(int $id): ?array
{
    $query = http_build_query([
        'select' => '*',
        'id_user' => 'eq.' . $id,
        'limit' => '1',
    ]);

    $result = supabaseRequest('users?' . $query);

    if (!$result['ok'] || empty($result['data'])) {
        return null;
    }

    return $result['data'][0];
}

function createRegularUser(string $name, string $email, string $password): array
{
    $passwordHash = password_hash($password, PASSWORD_BCRYPT);

    return supabaseRequest('users', 'POST', [
        'nama' => trim($name),
        'email' => strtolower(trim($email)),
        'password' => $passwordHash,
        'role' => 'user',
    ]);
}

function updateRegularUser(int $id, string $name, string $email, string $password = ''): array
{
    $payload = [
        'nama' => trim($name),
        'email' => strtolower(trim($email)),
    ];

    if ($password !== '') {
        $payload['password'] = password_hash($password, PASSWORD_BCRYPT);
    }

    return supabaseRequest('users?id_user=eq.' . $id, 'PATCH', $payload);
}

function deleteRegularUser(int $id): array
{
    return supabaseRequest('users?id_user=eq.' . $id, 'DELETE');
}
