-- Detalles de seguridad de cada usuario
SELECT 
    dp.name AS 'Usuario',
    dp.type_desc AS 'TipoUsuario',
    dpr.name AS 'Rol',
    schema_name(tab.schema_id) + '.' + tab.name AS 'Tabla',
    perm.permission_name AS 'PermisoTabla',
    schema_name(sp.schema_id) + '.' + sp.name AS 'ProcedimientoAlmacenado',
    perm_sp.permission_name AS 'PermisoProcedimiento',
    schema_name(vw.schema_id) + '.' + vw.name AS 'Vista',
    perm_vw.permission_name AS 'PermisoVista'
FROM 
    sys.database_principals dp
LEFT JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
LEFT JOIN sys.database_principals dpr ON drm.role_principal_id = dpr.principal_id
LEFT JOIN sys.tables tab ON dp.principal_id = tab.principal_id
LEFT JOIN sys.database_permissions perm ON tab.object_id = perm.major_id AND dp.principal_id = perm.grantee_principal_id
LEFT JOIN sys.procedures sp ON dp.principal_id = sp.principal_id
LEFT JOIN sys.database_permissions perm_sp ON sp.object_id = perm_sp.major_id AND dp.principal_id = perm_sp.grantee_principal_id
LEFT JOIN sys.views vw ON dp.principal_id = vw.principal_id
LEFT JOIN sys.database_permissions perm_vw ON vw.object_id = perm_vw.major_id AND dp.principal_id = perm_vw.grantee_principal_id
WHERE 
    dp.type_desc IN ('SQL_USER', 'WINDOWS_USER', 'WINDOWS_GROUP')
ORDER BY 
    dp.name, dpr.name, schema_name(tab.schema_id) + '.' + tab.name, perm.permission_name,
    schema_name(sp.schema_id) + '.' + sp.name, perm_sp.permission_name,
    schema_name(vw.schema_id) + '.' + vw.name, perm_vw.permission_name;
