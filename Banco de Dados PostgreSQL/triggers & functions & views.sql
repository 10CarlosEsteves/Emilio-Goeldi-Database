--Pesquisa Suprema
SELECT 
	res.gbifid,
	rig.access_rights,
	rig.license,
	rig.rights_holder,
	rig.institution_code,
	res.collection_code,
	res.basis_of_record,
	res.ocurrenceid,
	STRING_AGG(rese.surname || ', ' || rese.name, '; ') AS nomes_concatenados,
	res.ocurrence_status,
	res.preparations,
	res.event_date,
	res.event_remarks,
	res.localization_id,
	con.continent_name,
	cou.country_name,
	sta.state_name,
	cit.city_name,
	loc.localization_name,
	loc.decimal_latitude,
	loc.decimal_longitude,
	tas.type_status,
	tax.scientific_name
	
FROM research res
JOIN rights rig ON rig.id = res.license_rights
JOIN researched_by rby ON rby.gbifid = res.gbifid
JOIN researcher rese ON rese.id = rby.researcher_id
JOIN localization loc ON loc.id = res.localization_id
JOIN city cit ON cit.id = loc.city_id
JOIN state_table sta ON sta.id = cit.state_id
JOIN country cou ON cou.id = sta.country_id
JOIN continent con ON con.id = cou.continent_id
JOIN taxon_sample tas ON tas.gbifid = res.gbifid
JOIN taxon tax ON tax.id = tas.taxon_id
GROUP BY 
	res.gbifid,
	rig.access_rights,
	rig.license,
	rig.rights_holder,
	rig.institution_code,
	res.collection_code,
	res.basis_of_record,
	res.ocurrenceid,
	res.ocurrence_status,
	res.preparations,
	res.event_date,
	res.event_remarks,
	res.localization_id,
	con.continent_name,
	cou.country_name,
	sta.state_name,
	cit.city_name,
	loc.localization_name,
	loc.decimal_latitude,
	loc.decimal_longitude,
	tas.type_status,
	tax.scientific_name
ORDER BY (res.gbifid) DESC;


--View para densidade de criaturas
CREATE OR REPLACE VIEW taxon_density AS
SELECT 
	cou.country_name,
	sta.state_name,
	cit.city_name,
	loc.localization_name,
	loc.decimal_latitude,
	loc.decimal_longitude,
	tax.scientific_name,
	COUNT(tas.taxon_id) AS "Quantity"
	
	FROM research res
	JOIN localization loc ON loc.id = res.localization_id
	JOIN city cit ON cit.id = loc.city_id
	JOIN state_table sta ON sta.id = cit.state_id
	JOIN country cou ON cou.id = sta.country_id
	JOIN taxon_sample tas ON res.gbifid = tas.gbifid
	JOIN taxon tax ON tax.id = tas.taxon_id
	WHERE loc.decimal_latitude IS NOT NULL AND loc.decimal_longitude IS NOT NULL
	GROUP BY(
		cou.country_name,
		sta.state_name,
		cit.city_name,
		loc.localization_name,
		loc.decimal_latitude,
		loc.decimal_longitude,
		tax.scientific_name
	)
	ORDER BY("Quantity") DESC;

--View para a linha do tempo das expedições dos pesquisadores
CREATE OR REPLACE VIEW researchers_timeline AS
SELECT 
	res.gbifid AS "gbifID",
	STRING_AGG(rer.surname || ', ' || rer.name, '; ') AS "Researchers Team",
	res.event_date AS "Event Date"
	FROM research res
	JOIN researched_by reb ON reb.gbifid = res.gbifid
	JOIN researcher rer ON rer.id = reb.researcher_id
	WHERE res.event_date IS NOT NULL
	GROUP BY(res.gbifid, res.event_date)
	ORDER BY(res.gbifid) DESC;
	
--View para a quantidade de Issues
CREATE OR REPLACE VIEW issues_quantity AS
SELECT 
	iss.issue_name AS Issue,
	COUNT(iss.id) AS Quantity
	FROM research res 
	JOIN research_issue rei ON rei.gbifid = res.gbifid
	JOIN issue iss ON iss.id = rei.issue_id
	GROUP BY(iss.id)
	ORDER BY(Quantity) DESC;
	
--Esta view mostra a quantidade total de taxons descobertos
CREATE OR REPLACE VIEW taxon_quantity AS 
SELECT
	tax.scientific_name AS "Scientific Name",
	COUNT(tax.id) AS "Quantity Discovered"
	FROM research res
	JOIN taxon_sample tas ON tas.gbifid = RES.gbifid
	JOIN taxon tax ON tax.id = tas.taxon_id
	GROUP BY(tax.id)
	ORDER BY("Quantity Discovered") DESC;

--Esta view mostra a quantidade total de taxons descobertos por determinados grupos de pesquisadores
CREATE OR REPLACE VIEW researchers_team_discover AS	
SELECT
	sub_query.researchers_team AS "Researchers Team",
	COUNT(sub_query.id) AS "Quantity Discovered"
	FROM
	(SELECT 
		res.gbifid AS gbifid,
		STRING_AGG(rer.surname || ', ' || rer.name, '; ') AS researchers_team,
		tax.id AS id

		FROM research res
		JOIN researched_by reb ON reb.gbifid = res.gbifid
		JOIN researcher rer ON rer.id = reb.researcher_id
		JOIN taxon_sample tas ON tas.gbifid = res.gbifid
		JOIN taxon tax ON tax.id = tas.taxon_id
		GROUP BY(res.gbifid, tax.id)
		ORDER BY(res.gbifid) DESC) AS sub_query
		GROUP BY(sub_query.researchers_team)
		ORDER BY("Quantity Discovered") DESC;
		
SELECT 
	tax.id,
	tax.scientific_name
	FROM taxon_sample tas
	JOIN taxon tax ON tax.id = tas.taxon_id
	GROUP BY(tax.id, tax.scientific_name)
	ORDER BY tax.id;
	
	
	
	
	
SELECT * FROM log;

-- Inicio do Trigger De Pesquisas
CREATE OR REPLACE FUNCTION register_research()
RETURNS TRIGGER AS $$ 
DECLARE
	eventType CHARACTER VARYING(50);
	userName CHARACTER VARYING(50);
	eventDescription TEXT;
	datasetKey TEXT;
	Protocol CHARACTER VARYING(20);
	eventDate TIMESTAMP;
BEGIN
	userName := current_user;
	datasetKey := '9c48ee0b-404a-4c84-9af0-946eef39ddca';
	Protocol := 'EML';
	eventDate := current_timestamp;
	
	IF TG_OP = 'INSERT' THEN
		eventType := 'INSERT AT RESEARCH';
		eventDescription := CONCAT(
        'NEW DATA: ',
        NEW.gbifid, ', ',
        NEW.license_rights, ', ',
        COALESCE(NEW.collection_code, 'null'), ', ',
        COALESCE(NEW.ocurrenceid, 'null'), ', ',
        COALESCE(NEW.basis_of_record, 'null'), ', ',
        COALESCE(NEW.ocurrence_status, 'null'), ', ',
        COALESCE(NEW.preparations, 'null'), ', ',
        COALESCE(NEW.event_date, current_date), ', ',
        COALESCE(NEW.event_remarks, 'null'), ', ',
        NEW.publishing_country, ', ',
        NEW.localization_id
    );
		
	ELSEIF TG_OP = 'UPDATE' THEN
		eventType := 'UPDATE AT RESEARCH';
		eventDescription := CONCAT(
        'NEW DATA: ',
        NEW.gbifid, ', ',
        NEW.license_rights, ', ',
        COALESCE(NEW.collection_code, 'null'), ', ',
        COALESCE(NEW.ocurrenceid, 'null'), ', ',
        COALESCE(NEW.basis_of_record, 'null'), ', ',
        COALESCE(NEW.ocurrence_status, 'null'), ', ',
        COALESCE(NEW.preparations, 'null'), ', ',
        COALESCE(NEW.event_date, current_date), ', ',
        COALESCE(NEW.event_remarks, 'null'), ', ',
        NEW.publishing_country, ', ',
        NEW.localization_id
    );
		
	ELSEIF TG_OP = 'DELETE' THEN
    eventType := 'DELETE AT RESEARCH';
    eventDescription := CONCAT(
        'OLD DATA: ',
        OLD.gbifid, ', ',
        OLD.license_rights, ', ',
        COALESCE(OLD.collection_code, 'null'), ', ',
        COALESCE(OLD.ocurrenceid, 'null'), ', ',
        COALESCE(OLD.basis_of_record, 'null'), ', ',
        COALESCE(OLD.ocurrence_status, 'null'), ', ',
        COALESCE(OLD.preparations, 'null'), ', ',
        COALESCE(OLD.event_date, current_date), ', ',
        COALESCE(OLD.event_remarks, 'null'), ', ',
        OLD.publishing_country, ', ',
        OLD.localization_id
    );
	END IF;
	
	INSERT INTO 
	log(event_type, user_name, event_description, dataset_key, protocol, event_date) 
	VALUES(eventType, userName, eventDescription, datasetKey, Protocol, eventDate);
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER log_research
BEFORE INSERT OR UPDATE OR DELETE ON research
FOR EACH ROW
EXECUTE PROCEDURE register_research();
-- Fim do Trigger De Pesquisas



-- Inicio do Trigger De Taxon
CREATE OR REPLACE FUNCTION register_taxon()
RETURNS TRIGGER AS $$ 
DECLARE
	eventType CHARACTER VARYING(50);
	userName CHARACTER VARYING(50);
	eventDescription TEXT;
	datasetKey TEXT;
	Protocol CHARACTER VARYING(20);
	eventDate TIMESTAMP;
BEGIN
	userName := current_user;
	datasetKey := '9c48ee0b-404a-4c84-9af0-946eef39ddca';
	Protocol := 'EML';
	eventDate := current_timestamp;
	
	IF TG_OP = 'INSERT' THEN
		eventType := 'INSERT AT TAXON';
		eventDescription := CONCAT(
        'NEW DATA: ',
		NEW.id, ', ',
        NEW.taxon_hierarchy_id, ', ',
        NEW.taxon_key, ', ',
        COALESCE(NEW.scientific_name, 'null'), ', ',
        COALESCE(NEW.generic_name, 'Unknow'), ', ',
        COALESCE(NEW.specific_epithet, 'Unknow'), ', ',
        COALESCE(NEW.infraespecific_epithet, 'Unknow'), ', ',
        COALESCE(NEW.taxon_rank, 'Unknow'), ', ',
        COALESCE(NEW.taxonomic_status, 'Unknow'), ', ',
        COALESCE(NEW.iucn_redlist_category, 'null'), ', '
    );
		
	ELSEIF TG_OP = 'UPDATE' THEN
		eventType := 'UPDATE AT TAXON';
		eventDescription := CONCAT(
        'NEW DATA: ',
		NEW.id, ', ',
        NEW.taxon_hierarchy_id, ', ',
        NEW.taxon_key, ', ',
        COALESCE(NEW.scientific_name, 'null'), ', ',
        COALESCE(NEW.generic_name, 'Unknow'), ', ',
        COALESCE(NEW.specific_epithet, 'Unknow'), ', ',
        COALESCE(NEW.infraespecific_epithet, 'Unknow'), ', ',
        COALESCE(NEW.taxon_rank, 'Unknow'), ', ',
        COALESCE(NEW.taxonomic_status, 'Unknow'), ', ',
        COALESCE(NEW.iucn_redlist_category, 'null'), ', '
    );
	
	ELSEIF TG_OP = 'DELETE' THEN
    eventType := 'DELETE AT TAXON';
    eventDescription := CONCAT(
        'OLD DATA: ',
        OLD.id, ', ',
        OLD.taxon_hierarchy_id, ', ',
        OLD.taxon_key, ', ',
        COALESCE(OLD.scientific_name, 'null'), ', ',
        COALESCE(OLD.generic_name, 'Unknow'), ', ',
        COALESCE(OLD.specific_epithet, 'Unknow'), ', ',
        COALESCE(OLD.infraespecific_epithet, 'Unknow'), ', ',
        COALESCE(OLD.taxon_rank, 'Unknow'), ', ',
        COALESCE(OLD.taxonomic_status, 'Unknow'), ', ',
        COALESCE(OLD.iucn_redlist_category, 'null'), ', '
    );
	
	END IF;
	
	INSERT INTO 
	log(event_type, user_name, event_description, dataset_key, protocol, event_date) 
	VALUES(eventType, userName, eventDescription, datasetKey, Protocol, eventDate);
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER log_taxon
BEFORE INSERT OR UPDATE OR DELETE ON taxon
FOR EACH ROW
EXECUTE PROCEDURE register_taxon();
-- Fim do Trigger De Taxon


SELECT * FROM researcher;
-- Inicio do Trigger De Researcher
CREATE OR REPLACE FUNCTION register_researcher()
RETURNS TRIGGER AS $$ 
DECLARE
	eventType CHARACTER VARYING(50);
	userName CHARACTER VARYING(50);
	eventDescription TEXT;
	datasetKey TEXT;
	Protocol CHARACTER VARYING(20);
	eventDate TIMESTAMP;
BEGIN
	userName := current_user;
	datasetKey := '9c48ee0b-404a-4c84-9af0-946eef39ddca';
	Protocol := 'EML';
	eventDate := current_timestamp;
	
	IF TG_OP = 'INSERT' THEN
		eventType := 'INSERT AT RESEARCHER';
		eventDescription := CONCAT(
        'NEW DATA: ',
		NEW.id, ', ',
        COALESCE(NEW.name, ' '), ', ',
        COALESCE(NEW.surname, ' ')
    );
		
	ELSEIF TG_OP = 'UPDATE' THEN
    eventType := 'UPDATE AT RESEARCHER';
    eventDescription := CONCAT(
        'NEW DATA: ',
        NEW.id, ', ',
        COALESCE(NEW.name, ' '), ', ',
        COALESCE(NEW.surname, ' ')
    );
	
	ELSEIF TG_OP = 'DELETE' THEN
		eventType := 'DELETE AT RESEARCHER';
		eventDescription := CONCAT(
        'OLD DATA: ',
		OLD.id, ', ',
        COALESCE(OLD.name, ' '), ', ',
        COALESCE(OLD.surname, ' ')
    );
	
	END IF;
	
	INSERT INTO 
	log(event_type, user_name, event_description, dataset_key, protocol, event_date) 
	VALUES(eventType, userName, eventDescription, datasetKey, Protocol, eventDate);
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER log_researcher
BEFORE INSERT OR UPDATE OR DELETE ON researcher
FOR EACH ROW
EXECUTE PROCEDURE register_researcher();
-- Fim do Trigger De Researcher



-- Inicio do Trigger De Issue
CREATE OR REPLACE FUNCTION register_issue()
RETURNS TRIGGER AS $$ 
DECLARE
	eventType CHARACTER VARYING(50);
	userName CHARACTER VARYING(50);
	eventDescription TEXT;
	datasetKey TEXT;
	Protocol CHARACTER VARYING(20);
	eventDate TIMESTAMP;
BEGIN
	userName := current_user;
	datasetKey := '9c48ee0b-404a-4c84-9af0-946eef39ddca';
	Protocol := 'EML';
	eventDate := current_timestamp;
	
	IF TG_OP = 'INSERT' THEN
		eventType := 'INSERT AT ISSUE';
		eventDescription := CONCAT(
        'NEW DATA: ',
		NEW.id, ', ',
        NEW.issue_name
    );
		
	ELSEIF TG_OP = 'UPDATE' THEN
		eventType := 'UPDATE AT ISSUE';
		eventDescription := CONCAT(
        'NEW DATA: ',
		NEW.id, ', ',
        NEW.issue_name
    );
	
	ELSEIF TG_OP = 'DELETE' THEN
		eventType := 'DELETE AT ISSUE';
		eventDescription := CONCAT(
        'OLD DATA: ',
		OLD.id, ', ',
        OLD.issue_name
    );
	
	END IF;
	
	INSERT INTO 
	log(event_type, user_name, event_description, dataset_key, protocol, event_date) 
	VALUES(eventType, userName, eventDescription, datasetKey, Protocol, eventDate);
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER log_issue
BEFORE INSERT OR UPDATE OR DELETE ON issue
FOR EACH ROW
EXECUTE PROCEDURE register_issue();
-- Fim do Trigger De Issue



-- Inicio do Trigger De Issue
CREATE OR REPLACE FUNCTION register_rights()
RETURNS TRIGGER AS $$ 
DECLARE
	eventType CHARACTER VARYING(50);
	userName CHARACTER VARYING(50);
	eventDescription TEXT;
	datasetKey TEXT;
	Protocol CHARACTER VARYING(20);
	eventDate TIMESTAMP;
BEGIN
	userName := current_user;
	datasetKey := '9c48ee0b-404a-4c84-9af0-946eef39ddca';
	Protocol := 'EML';
	eventDate := current_timestamp;
	
	IF TG_OP = 'INSERT' THEN
		eventType := 'INSERT AT RIGHTS';
		eventDescription := CONCAT(
        'NEW DATA: ',
		NEW.id, ', ',
        NEW.license, ', ',
		NEW.access_rights, ', ',
		NEW.rights_holder, ', ',
		NEW.institution_code
    );
		
	ELSEIF TG_OP = 'UPDATE' THEN
    eventType := 'UPDATE AT RIGHTS';
    eventDescription := CONCAT(
        'NEW DATA: ',
        NEW.id, ', ',
        NEW.license, ', ',
        NEW.access_rights, ', ',
        NEW.rights_holder, ', ',
        NEW.institution_code
    );
	
	ELSEIF TG_OP = 'DELETE' THEN
		eventType := 'DELETE AT RIGHTS';
		eventDescription := CONCAT(
        'OLD DATA: ',
		OLD.id, ', ',
        OLD.license, ', ',
		OLD.access_rights, ', ',
		OLD.rights_holder, ', ',
		OLD.institution_code
    );
	
	END IF;
	
	INSERT INTO 
	log(event_type, user_name, event_description, dataset_key, protocol, event_date) 
	VALUES(eventType, userName, eventDescription, datasetKey, Protocol, eventDate);
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER log_rights
BEFORE INSERT OR UPDATE OR DELETE ON rights
FOR EACH ROW
EXECUTE PROCEDURE register_rights();
-- Fim do Trigger De Issue


SELECT * FROM localization;
-- Inicio do Trigger De Localization
CREATE OR REPLACE FUNCTION register_localization()
RETURNS TRIGGER AS $$ 
DECLARE
	eventType CHARACTER VARYING(50);
	userName CHARACTER VARYING(20);
	eventDescription TEXT;
	datasetKey TEXT;
	Protocol CHARACTER VARYING(20);
	eventDate TIMESTAMP;
BEGIN
	userName := current_user;
	datasetKey := '9c48ee0b-404a-4c84-9af0-946eef39ddca';
	Protocol := 'EML';
	eventDate := current_timestamp;
	
	IF TG_OP = 'INSERT' THEN
		eventType := 'INSERT AT LOCALIZATION';
		eventDescription := CONCAT(
        'NEW DATA: ',
		NEW.id, ', ',
        NEW.city_id, ', ',
		NEW.localization_name, ', ',
		NEW.decimal_latitude, ', ',
		NEW.decimal_longitude
    );
		
	ELSEIF TG_OP = 'UPDATE' THEN
		eventType := 'UPDATE AT LOCALIZATION';
		eventDescription := CONCAT(
        'NEW DATA: ',
		NEW.id, ', ',
        NEW.city_id, ', ',
		NEW.localization_name, ', ',
		NEW.decimal_latitude, ', ',
		NEW.decimal_longitude
    );
	
	ELSEIF TG_OP = 'DELETE' THEN
    eventType := 'DELETE AT LOCALIZATION';
    eventDescription := CONCAT(
        'OLD DATA: ',
        OLD.id, ', ',
        OLD.city_id,', ',
        OLD.localization_name, ', ',
        OLD.decimal_latitude, ', ',
        OLD.decimal_longitude
    );
	
	END IF;
	
	INSERT INTO 
	log(event_type, user_name, event_description, dataset_key, protocol, event_date) 
	VALUES(eventType, userName, eventDescription, datasetKey, Protocol, eventDate);
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER log_localization
BEFORE INSERT OR UPDATE OR DELETE ON localization
FOR EACH ROW
EXECUTE PROCEDURE register_localization();
-- Fim do Trigger De Localization



--Função do Diretor
CREATE OR REPLACE FUNCTION update_last_parsed()
RETURNS VOID AS $$ 
DECLARE
    log_record RECORD;
BEGIN
    FOR log_record IN SELECT * FROM log LOOP
        -- Atualiza a coluna last_parsed para a data atual
        UPDATE log
        SET last_parsed = CURRENT_TIMESTAMP
        WHERE id = log_record.id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
