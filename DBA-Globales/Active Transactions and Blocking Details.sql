-- Estado de las consultas en ejeución

select database_id, db_name(database_id) dbname, database_transaction_begin_time, database_transaction_state, database_transaction_log_record_count, database_transaction_log_bytes_used, database_transaction_begin_lsn, stran.session_id from sys.dm_tran_database_transactions dbtran left outer join sys.dm_tran_session_transactions stran on dbtran.transaction_id = stran.transaction_id where database_id = 5


-----VERIFICAR BLOQUEO DE TRANSACCIONES Y QUE CONSULTA LA BLOQUEA

SELECT tst.session_id, [database_name] = db_name(s.database_id)
, tat.transaction_begin_time
, transaction_duration_s = datediff(s, tat.transaction_begin_time, sysdatetime()) 
, transaction_type = CASE tat.transaction_type  WHEN 1 THEN 'Read/write transaction'
                                                WHEN 2 THEN 'Read-only transaction'
                                                WHEN 3 THEN 'System transaction'
                                                WHEN 4 THEN 'Distributed transaction' END
, s.login_name
, s.program_name
, input_buffer = ib.event_info, tat.transaction_uow  
, transaction_state  = CASE tat.transaction_state    
            WHEN 0 THEN 'La transacción aún no se ha inicializado por completo..'
            WHEN 1 THEN 'La transacción se ha inicializado pero no ha comenzado.'
            WHEN 2 THEN 'La transacción está activa: no se ha comprometido ni revertido.'
            WHEN 3 THEN 'La transacción ha finalizado. Esto se usa para transacciones de solo lectura.'
            WHEN 4 THEN 'El proceso de confirmación se ha iniciado en la transacción distribuida.'
            WHEN 5 THEN 'La transacción está en un estado preparado y esperando resolución.'
            WHEN 6 THEN 'La transacción ha sido comprometida.'
            WHEN 7 THEN 'La transacción se está revirtiendo.'
            WHEN 8 THEN 'La transacción ha sido revertida.' END 
, s.host_name
, transaction_name = tat.name, request_status = r.status
, tst.is_user_transaction, tst.is_local
, session_open_transaction_count = tst.open_transaction_count  
, s.client_interface_name, s.is_user_process 
FROM sys.dm_tran_active_transactions tat 
INNER JOIN sys.dm_tran_session_transactions tst  on tat.transaction_id = tst.transaction_id
INNER JOIN Sys.dm_exec_sessions s on s.session_id = tst.session_id 
LEFT OUTER JOIN sys.dm_exec_requests r on r.session_id = s.session_id
CROSS APPLY sys.dm_exec_input_buffer(s.session_id, null) AS ib
--where transaction_duration_s > '25'
order by transaction_duration_s DESC