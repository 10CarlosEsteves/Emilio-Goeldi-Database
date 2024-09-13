--Tabela de Direitos
CREATE TABLE rights(
    id SERIAL PRIMARY KEY,
    license CHARACTER VARYING(15) NOT NULL,
    access_rights CHARACTER VARYING(100) NOT NULL,
    rights_holder CHARACTER VARYING(50) NOT NULL,
    institution_code CHARACTER VARYING(6) NOT NULL
);

--Tabela de Continente
CREATE TABLE continent(
    id SERIAL PRIMARY KEY,
    continent_name CHARACTER VARYING(20) NOT NULL UNIQUE
);

--Tabela de País
CREATE TABLE country(
    id SERIAL PRIMARY KEY,
    continent_id INTEGER NOT NULL,
	level0Gid CHARACTER VARYING(5),
    country_name CHARACTER VARYING(30) NOT NULL UNIQUE,

    FOREIGN KEY (continent_id) REFERENCES continent (id)
);

--Tabela de Estados
CREATE TABLE state_table(
    id SERIAL PRIMARY KEY,
    country_id INTEGER NOT NULL,
	level1Gid CHARACTER VARYING(15),
    state_name CHARACTER VARYING(20) NOT NULL,

    FOREIGN KEY (country_id) REFERENCES country (id)
);

--Tabela de Cidades
CREATE TABLE city(
    id SERIAL PRIMARY KEY,
    state_id INTEGER NOT NULL,
	level2Gid CHARACTER VARYING(15),
    city_name CHARACTER VARYING(30) NOT NULL,
	
	UNIQUE(state_id, level2Gid, city_name),
    FOREIGN KEY (state_id) REFERENCES state_table (id)
);

--Tabela de Localização
CREATE TABLE localization(
    id SERIAL PRIMARY KEY,
    city_id INTEGER NOT NULL,
    localization_name CHARACTER VARYING(255) NOT NULL,
    decimal_latitude DECIMAL(10, 6),
    decimal_longitude DECIMAL(10, 6),
	
	UNIQUE(city_id, localization_name, decimal_latitude, decimal_longitude),
    FOREIGN KEY (city_id) REFERENCES city (id)
);

--Tabela Contendo Dados do Pesquisador
CREATE TABLE researcher(
    id SERIAL PRIMARY KEY,
    name CHARACTER VARYING(80) NOT NULL,
    surname CHARACTER VARYING(80) NOT NULL,
    email  CHARACTER VARYING(50),
    password CHARACTER VARYING(255),
	telephone CHARACTER VARYING(11),
	address CHARACTER VARYING(255)
);

--Tabela de Grupos de Pesquisa
CREATE TABLE research_group(
	ID SERIAL PRIMARY KEY,
	name CHARACTER VARYING(80) NOT NULL,
	description TEXT NOT NULL,
	institution CHARACTER VARYING(80) NOT NULL
);

--Tabela Intermediária de pesquisador e cargo em grupo de pesquisa
CREATE TABLE member_of(
	researcher_id INTEGER NOT NULL,
	group_id INTEGER NOT NULL,
	researcher_role CHARACTER VARYING(10) CHECK(researcher_role in ('Admin', 'Researcher')) NOT NULL,

	FOREIGN KEY (researcher_id) REFERENCES researcher(id),
	FOREIGN KEY (group_id) REFERENCES research_group(id)
);

--Tabela de Pesquisa
CREATE TABLE research(
    gbifID BIGINT PRIMARY KEY,
	research_groupid INTEGER,
    license_rights INTEGER NOT NULL,
	collection_code CHARACTER VARYING(30) NOT NULL,
    ocurrenceID CHARACTER VARYING(30) UNIQUE NOT NULL,
    basis_of_record CHARACTER VARYING(30),
    ocurrence_status CHARACTER VARYING(15),
    preparations CHARACTER VARYING(15),
    event_date DATE,
    event_remarks TEXT,
    publishing_country INTEGER NOT NULL,
    localization_id INTEGER NOT NULL,

	FOREIGN KEY (research_groupid) REFERENCES research_group(id),
    FOREIGN KEY (license_rights) REFERENCES rights (id),
    FOREIGN KEY (publishing_country) REFERENCES country(id),
    FOREIGN KEY (localization_id) REFERENCES localization (id)
);

--Tabela Intermediária de pesquisador e pesquisa
CREATE TABLE researched_by(
    gbifID BIGINT,
    researcher_id INTEGER,

    PRIMARY KEY(gbifID, researcher_id),

    FOREIGN KEY (gbifID) REFERENCES research (gbifID) ON DELETE CASCADE,
    FOREIGN KEY (researcher_id) REFERENCES researcher (id)
);

--Tabela de Problemas
CREATE TABLE issue(
    id SERIAL PRIMARY KEY,
    issue_name TEXT NOT NULL
);

--Tabela de Problemas Relacionados a Pesquisa
CREATE TABLE research_issue(
    gbifID BIGINT,
    issue_id INTEGER,

    PRIMARY KEY(gbifID, issue_id),

    FOREIGN KEY (gbifID) REFERENCES research (gbifID)  ON DELETE CASCADE,
    FOREIGN KEY (issue_id) REFERENCES issue (id)
);

--Tabela de Reino
CREATE TABLE kingdom(
    id SERIAL PRIMARY KEY,
    kingdom_key INTEGER,
    kingdom_name CHARACTER VARYING(20) NOT NULL DEFAULT 'Incertae Sedis',
    UNIQUE(kingdom_key, kingdom_name)
);

--Tabela de Filo
CREATE TABLE phylum(
    id SERIAL PRIMARY KEY,
    phylum_key INTEGER,
    phylum_name CHARACTER VARYING(20) NOT NULL DEFAULT 'Unknow',
    UNIQUE(phylum_key, phylum_name)
);

--Tabela de Classe
CREATE TABLE class_table(
    id SERIAL PRIMARY KEY,
    class_key INTEGER,
    class_name CHARACTER VARYING(20) NOT NULL DEFAULT 'Unknow',
    UNIQUE(class_key, class_name)
);

--Tabela de Ordem
CREATE TABLE order_table(
    id SERIAL PRIMARY KEY,
    order_key INTEGER,
    order_name CHARACTER VARYING(20) NOT NULL DEFAULT 'Unknow',
    UNIQUE(order_key, order_name)
);

--Tabela de Família
CREATE TABLE family_table(
    id SERIAL PRIMARY KEY,
    family_key INTEGER,
    family_name CHARACTER VARYING(20) NOT NULL DEFAULT 'Unknow',
    UNIQUE(family_key, family_name)
);

--Tabela de Gênero
CREATE TABLE genus(
    id SERIAL PRIMARY KEY,
    genus_key INTEGER,
    genus_name CHARACTER VARYING(20) NOT NULL DEFAULT 'Unknow',
    UNIQUE(genus_key, genus_name)
);

--Tabela de Espécie
CREATE TABLE species(
    id SERIAL PRIMARY KEY,
    species_key INTEGER,
    species_name CHARACTER VARYING(255) NOT NULL DEFAULT 'Unknow',
    UNIQUE(species_key, species_name)
);

--Tabela de Hierárquia de Táxon
/*
A ideia central é criar uma combinação entres as tabelas menores
uma vez que um táxon é categorizado por uma entidade formada por
uma combinação de tabelas menores
*/
CREATE TABLE taxon_hierarchy(
    id SERIAL PRIMARY KEY,
    kingdom_id INTEGER NOT NULL,
    phylum_id INTEGER NOT NULL,
    class_table_id INTEGER NOT NULL,
    order_table_id INTEGER NOT NULL,
    family_table_id INTEGER NOT NULL,
    genus_id INTEGER NOT NULL,
    species_id INTEGER NOT NULL,
    
    UNIQUE(kingdom_id, phylum_id, class_table_id, order_table_id, family_table_id, genus_id, species_id),

    FOREIGN KEY (kingdom_id) REFERENCES kingdom (id),
    FOREIGN KEY (phylum_id) REFERENCES phylum (id),
    FOREIGN KEY (class_table_id) REFERENCES class_table (id),
    FOREIGN KEY (order_table_id) REFERENCES order_table (id),
    FOREIGN KEY (family_table_id) REFERENCES family_table (id),
    FOREIGN KEY (genus_id) REFERENCES genus (id),
    FOREIGN KEY (species_id) REFERENCES species (id)
);

--Tabela de Táxon
CREATE TABLE taxon (
    id SERIAL PRIMARY KEY,
    taxon_hierarchy_id INTEGER NOT NULL,
    taxon_key BIGINT,
    scientific_name CHARACTER VARYING(80) NOT NULL,
    generic_name CHARACTER VARYING(40),
    specific_epithet CHARACTER VARYING(20),
    infraespecific_epithet CHARACTER VARYING(20),
    taxon_rank CHARACTER VARYING(12) NOT NULL,
    taxonomic_status CHARACTER VARYING(12),
    iucn_redlist_category CHARACTER VARYING(2) CHECK(iucn_redlist_category in ('EX','EW','CR','PT','VU','NT','CD','LC','DD','NE')),
	
	UNIQUE(taxon_hierarchy_id,taxon_key,scientific_name,generic_name,specific_epithet,infraespecific_epithet,taxon_rank,taxonomic_status,iucn_redlist_category),
    FOREIGN KEY (taxon_hierarchy_id) REFERENCES taxon_hierarchy (id)
);

--Tabela de Amostras de Táxon
CREATE TABLE taxon_sample(
	gbifID BIGINT NOT NULL,
	taxon_id INTEGER NOT NULL,
	verbatim_scientific_name CHARACTER VARYING(60),
	repatriated BOOL NOT NULL DEFAULT False, 
	type_status CHARACTER VARYING(12),

	FOREIGN KEY (gbifID) REFERENCES research (gbifID)  ON DELETE CASCADE,
    FOREIGN KEY (taxon_id) REFERENCES taxon (id)
);
	
--Tabela de Logs
CREATE TABLE log(
    id SERIAL PRIMARY KEY,
    event_type CHARACTER VARYING(50) NOT NULL,
    user_name CHARACTER VARYING(50) NOT NULL,
    event_description TEXT NOT NULL,
    dataset_key TEXT NOT NULL,
    protocol CHARACTER VARYING(20) NOT NULL,
    event_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_parsed TIMESTAMP
);

/*
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
*/
