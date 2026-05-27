<?php
require_once __DIR__ . '/../config/supabase.php';

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
    return supabaseRequest('users', 'POST', [
        'nama' => trim($name),
        'email' => strtolower(trim($email)),
        'password' => password_hash($password, PASSWORD_BCRYPT),
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
