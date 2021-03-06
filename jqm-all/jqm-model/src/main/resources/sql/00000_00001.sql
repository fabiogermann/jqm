/* Main database creation script. Designed for HSQLDB. JQM will adapt it to other compatible databases. */

CREATE SEQUENCE JQM_PK START WITH 1 INCREMENT BY 1;

/* Table used for tracking schema updates and version */
CREATE MEMORY TABLE VERSION
(
	ID INTEGER NOT NULL,
	COMPONENT VARCHAR(20) NOT NULL,
	VERSION_D1 INTEGER NOT NULL,
	VERSION_D2 INTEGER DEFAULT 0 NOT NULL,
	VERSION_D3 INTEGER DEFAULT 0 NOT NULL,
	COMPAT_D1 INTEGER,
	COMPAT_D2 INTEGER,
	COMPAT_D3 INTEGER,
	INSTALL_DATE TIMESTAMP NOT NULL,
	NOTES VARCHAR(100),
	
	CONSTRAINT PK_VERSION PRIMARY KEY(ID)
);

/* Deployment infra */
CREATE MEMORY TABLE NODE
(
	ID INTEGER NOT NULL,
	NAME VARCHAR(100) NOT NULL,
	DNS VARCHAR(255) NOT NULL,
	PORT INTEGER NOT NULL,
	ENABLED BOOLEAN,
	STOP BOOLEAN NOT NULL,
	JMX_REGISTRY_PORT INTEGER,
	JMX_SERVER_PORT INTEGER,
	LAST_SEEN_ALIVE TIMESTAMP NULL,
	LOAD_API_ADMIN BOOLEAN,
	LOAD_API_CLIENT BOOLEAN,
	LOAD_API_SIMPLE BOOLEAN,
	ROOT_LOG_LEVEL VARCHAR(10),
	REPO_JOB_DEF VARCHAR(1024) NOT NULL,
	REPO_DELIVERABLE VARCHAR(1024) NOT NULL,
	REPO_TMP VARCHAR(1024),
	
	CONSTRAINT PK_NODE PRIMARY KEY(ID),
	CONSTRAINT UK_NODE_1 UNIQUE(NAME)
);

CREATE MEMORY TABLE QUEUE
(
	ID INTEGER NOT NULL,
	DEFAULT_QUEUE BOOLEAN,
	DESCRIPTION VARCHAR(1000) NOT NULL,
	NAME VARCHAR(50) NOT NULL,
	TIME_TO_LIVE INTEGER NULL,
	
	CONSTRAINT PK_QUEUE PRIMARY KEY(ID),
	CONSTRAINT UK_QUEUE_1 UNIQUE(NAME)
);

CREATE MEMORY TABLE QUEUE_NODE_MAPPING
(
	ID INTEGER NOT NULL,
	ENABLED BOOLEAN,
	LAST_MODIFIED TIMESTAMP NULL,
	MAX_THREAD INTEGER NOT NULL,
	POLLING_INTERVAL INTEGER NOT NULL,
	NODE INTEGER NOT NULL,
	QUEUE INTEGER NOT NULL,
	
	CONSTRAINT PK_QUEUE_NODE_MAPPING PRIMARY KEY(ID),
	CONSTRAINT UK_QUEUE_NODE_MAPPING_1 UNIQUE(QUEUE, NODE),
	CONSTRAINT FK_QUEUE_NODE_MAPPING_1 FOREIGN KEY(NODE) REFERENCES NODE(ID),
	CONSTRAINT FK_QUEUE_NODE_MAPPING_2 FOREIGN KEY(QUEUE) REFERENCES QUEUE(ID)
);
CREATE INDEX IDX_FK_QUEUE_NODE_MAPPING_1 ON QUEUE_NODE_MAPPING(NODE);
CREATE INDEX IDX_FK_QUEUE_NODE_MAPPING_2 ON QUEUE_NODE_MAPPING(QUEUE);

/* Execution context */
CREATE MEMORY TABLE CL
(
	ID INTEGER NOT NULL,
	NAME VARCHAR(100) NOT NULL,
	CHILD_FIRST BOOLEAN NOT NULL,
	HIDDEN_CLASSES VARCHAR(1024),
	TRACING BOOLEAN NOT NULL,
	PERSISTENT BOOLEAN NOT NULL,
	ALLOWED_RUNNERS VARCHAR(1024),
	
	CONSTRAINT PK_CL PRIMARY KEY(ID),
	CONSTRAINT UK_CL_1 UNIQUE(NAME)
);

CREATE MEMORY TABLE CL_HANDLER
(
	ID INTEGER NOT NULL,
	EVENT_TYPE VARCHAR(100) NOT NULL,
	CLASS_NAME VARCHAR(1024),
	CL INTEGER NOT NULL,
	
	CONSTRAINT PK_CL_HANDLER PRIMARY KEY(ID),
	CONSTRAINT FK_CL_HANDLER_1 FOREIGN KEY(CL) REFERENCES CL(ID)
);
CREATE INDEX IDX_FK_CL_HANDLER_1 ON CL_HANDLER(CL);

CREATE MEMORY TABLE CL_HANDLER_PARAMETER
(
	ID INTEGER NOT NULL,
	KEYNAME VARCHAR(50) NOT NULL,
	VALUE VARCHAR(1000) NOT NULL,
	CL_HANDLER INTEGER NOT NULL,
	
	CONSTRAINT PK_CL_HANDLER_PARAMETER PRIMARY KEY(ID),
	CONSTRAINT FK_CL_HANDLER_PARAMETER_1 FOREIGN KEY(CL_HANDLER) REFERENCES CL_HANDLER(ID)
);
CREATE INDEX IDX_FK_CL_HANDLER_PARAMETER_1 ON CL_HANDLER_PARAMETER(CL_HANDLER);


/* Job definition */
CREATE MEMORY TABLE JOB_DEFINITION
(
	ID INTEGER NOT NULL,
	JD_KEY VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(1024),
	HIGHLANDER BOOLEAN NOT NULL,
	
	QUEUE INTEGER NOT NULL,
	
	ENABLED BOOLEAN NOT NULL,	
	RESTARTABLE BOOLEAN,
	
	PATH VARCHAR(1024),
	PATH_TYPE VARCHAR(255),
	CLASS_NAME VARCHAR(100) NOT NULL,
	EXTERNAL BOOLEAN NOT NULL,
	JAVA_OPTS VARCHAR(1024),
	
	CL INTEGER NULL,
	
	ALERT_AFTER_SECONDS INTEGER,
	
	APPLICATION VARCHAR(50),
	KEYWORD1 VARCHAR(50),
	KEYWORD2 VARCHAR(50),
	KEYWORD3 VARCHAR(50),
	MODULE VARCHAR(50),
	
	CONSTRAINT PK_JOB_DEFINITION PRIMARY KEY(ID),
	CONSTRAINT UK_JOB_DEFINITION_1 UNIQUE(JD_KEY),
	CONSTRAINT FK_JOBDEF_1 FOREIGN KEY(QUEUE) REFERENCES QUEUE(ID),
	CONSTRAINT FK_JOBDEF_2 FOREIGN KEY(CL) REFERENCES CL(ID)
);
CREATE INDEX IDX_FK_JOBDEF_1 ON JOB_DEFINITION(QUEUE);
CREATE INDEX IDX_FK_JOBDEF_2 ON JOB_DEFINITION(CL);

CREATE MEMORY TABLE JOB_DEFINITION_PARAMETER
(
	ID INTEGER NOT NULL,
	KEYNAME VARCHAR(50) NOT NULL,
	VALUE VARCHAR(1000) NOT NULL,
	JOBDEF INTEGER,
	
	CONSTRAINT PK_JOB_DEFINITION_PARAMETER PRIMARY KEY(ID),
	CONSTRAINT FK_JOB_DEFINITION_PARAMETER_1 FOREIGN KEY(JOBDEF) REFERENCES JOB_DEFINITION(ID)
);
CREATE INDEX IDX_FK_JOB_DEFINITION_PRM_1 ON JOB_DEFINITION_PARAMETER(JOBDEF);

CREATE MEMORY TABLE JOB_SCHEDULE
(
	ID INTEGER NOT NULL,
	CRON_EXPRESSION VARCHAR(254) NOT NULL,
	JOBDEF INTEGER NOT NULL,
	QUEUE INTEGER NULL,
	LAST_UPDATED TIMESTAMP NOT NULL,
	
	CONSTRAINT PK_JOB_SCHEDULE PRIMARY KEY(ID),
	CONSTRAINT FK_JOB_SCHEDULE_1 FOREIGN KEY(JOBDEF) REFERENCES JOB_DEFINITION(ID),
	CONSTRAINT FK_JOB_SCHEDULE_2 FOREIGN KEY(QUEUE) REFERENCES QUEUE(ID)
);
CREATE INDEX IDX_FK_JOB_SCHEDULE_1 ON JOB_SCHEDULE(JOBDEF);
CREATE INDEX IDX_FK_JOB_SCHEDULE_2 ON JOB_SCHEDULE(QUEUE);
CREATE INDEX IDX_JOB_SCHEDULE_1 ON JOB_SCHEDULE(LAST_UPDATED);

CREATE MEMORY TABLE JOB_SCHEDULE_PARAMETER
(
	ID INTEGER NOT NULL,
	KEYNAME VARCHAR(50) NOT NULL,
	VALUE VARCHAR(1000) NOT NULL,
	JOB_SCHEDULE INTEGER NOT NULL,
	
	CONSTRAINT PK_JOB_SCHEDULE_PARAMETER PRIMARY KEY(ID),
	CONSTRAINT FK_JOB_SCHEDULE_PARAMETER_1 FOREIGN KEY(JOB_SCHEDULE) REFERENCES JOB_SCHEDULE(ID),
	CONSTRAINT UK_JOB_SCHEDULER_PARAMETER_1 UNIQUE(KEYNAME, JOB_SCHEDULE)
);
CREATE INDEX IDX_FK_JOB_SCHEDULE_PRM_1 ON JOB_SCHEDULE_PARAMETER(JOB_SCHEDULE);

/* Execution and history */
CREATE MEMORY TABLE JOB_INSTANCE
(
	ID INTEGER NOT NULL,
	PARENT INTEGER,
	
	DATE_ENQUEUE TIMESTAMP NOT NULL,
	DATE_ATTRIBUTION TIMESTAMP NULL,
	DATE_START TIMESTAMP NULL,
	DATE_NOT_BEFORE TIMESTAMP NULL,
	
	INTERNAL_POSITION REAL NOT NULL,
	STATUS VARCHAR(20) NOT NULL,
	HIGHLANDER BOOLEAN,
	FROM_SCHEDULE BOOLEAN,
	
	EMAIL VARCHAR(255),
	
	APPLICATION VARCHAR(50),
	KEYWORD1 VARCHAR(50),
	KEYWORD2 VARCHAR(50),
	KEYWORD3 VARCHAR(50),
	MODULE VARCHAR(50),
	SESSION_KEY VARCHAR(255),
	USERNAME VARCHAR(50),
	
	PROGRESS INTEGER,
	
	JOBDEF INTEGER NOT NULL,
	NODE INTEGER,
	QUEUE INTEGER NOT NULL,
	
	CONSTRAINT PK_JOB_INSTANCE PRIMARY KEY(ID),
	CONSTRAINT FK_JOB_INSTANCE_1 FOREIGN KEY(JOBDEF) REFERENCES JOB_DEFINITION(ID),
	CONSTRAINT FK_JOB_INSTANCE_2 FOREIGN KEY(NODE) REFERENCES NODE(ID),
	CONSTRAINT FK_JOB_INSTANCE_3 FOREIGN KEY(QUEUE) REFERENCES QUEUE(ID)
);
CREATE INDEX IDX_JOB_INSTANCE_1 ON JOB_INSTANCE(QUEUE, STATUS);
CREATE INDEX IDX_JOB_INSTANCE_2 ON JOB_INSTANCE(JOBDEF, STATUS);
CREATE INDEX IDX_JOB_INSTANCE_3 ON JOB_INSTANCE(JOBDEF);
CREATE INDEX IDX_JOB_INSTANCE_4 ON JOB_INSTANCE(NODE);
CREATE INDEX IDX_JOB_INSTANCE_5 ON JOB_INSTANCE(QUEUE);

CREATE MEMORY TABLE HISTORY
(
	ID INTEGER NOT NULL, /* Not IDENTITY OR SEQUENCE!*/
	PARENT INTEGER,
	
	HIGHLANDER BOOLEAN,
	FROM_SCHEDULE BOOLEAN,
	
	PROGRESS INTEGER,
	RETURN_CODE INTEGER,
	STATUS VARCHAR(20) NOT NULL,
	
	DATE_ENQUEUE TIMESTAMP NOT NULL,
	DATE_ATTRIBUTION TIMESTAMP NULL,
	DATE_START TIMESTAMP NULL,
	DATE_END TIMESTAMP NULL,
	
	EMAIL VARCHAR(255),
	SESSION_KEY VARCHAR(255),
	USERNAME VARCHAR(255),
	
	INSTANCE_APPLICATION VARCHAR(50),
	INSTANCE_KEYWORD1 VARCHAR(50),
	INSTANCE_KEYWORD2 VARCHAR(50),
	INSTANCE_KEYWORD3 VARCHAR(50),
	INSTANCE_MODULE VARCHAR(50),
	JD_APPLICATION VARCHAR(50),
	JD_KEYWORD1 VARCHAR(50),
	JD_KEYWORD2 VARCHAR(50),
	JD_KEYWORD3 VARCHAR(50),
	JD_MODULE VARCHAR(50),
	
	JD_KEY VARCHAR(100) NOT NULL,
	NODE_NAME VARCHAR(100),
	QUEUE_NAME VARCHAR(50) NOT NULL,	
	JOBDEF INTEGER,
	NODE INTEGER,
	QUEUE INTEGER,
	
	CONSTRAINT PK_HISTORY PRIMARY KEY(ID),
	CONSTRAINT FK_HISTORY_1 FOREIGN KEY(JOBDEF) REFERENCES JOB_DEFINITION(ID) ON DELETE SET NULL,
	CONSTRAINT FK_HISTORY_2 FOREIGN KEY(NODE) REFERENCES NODE(ID) ON DELETE SET NULL,
	CONSTRAINT FK_HISTORY_3 FOREIGN KEY(QUEUE) REFERENCES QUEUE(ID) ON DELETE SET NULL
);
CREATE INDEX IDX_FK_HISTORY_1 ON HISTORY(JOBDEF);
CREATE INDEX IDX_FK_HISTORY_2 ON HISTORY(NODE);
CREATE INDEX IDX_FK_HISTORY_3 ON HISTORY(QUEUE);

CREATE MEMORY TABLE DELIVERABLE
(
	ID INTEGER NOT NULL,
	FILE_FAMILY VARCHAR(100),
	PATH VARCHAR(1024),
	JOB_INSTANCE INTEGER NOT NULL, /* Not an FK, as this is used by both Hostory and JobDef */
	ORIGINAL_FILE_NAME VARCHAR(1024),
	RANDOM_ID VARCHAR(200),
	
	CONSTRAINT PK_DELIVERABLE PRIMARY KEY(ID),
	CONSTRAINT UK_DELIVERABLE UNIQUE(RANDOM_ID)
);
CREATE INDEX IDX_FK_DELIVERABLE_1 ON DELIVERABLE(JOB_INSTANCE);

CREATE MEMORY TABLE JOB_INSTANCE_PARAMETER
(
	ID INTEGER NOT NULL,
	JOB_INSTANCE INTEGER, /* Not an FK, as this is used by both Hostory and JobDef */
	KEYNAME VARCHAR(50) NOT NULL,
	VALUE VARCHAR(1000) NOT NULL,
	
	CONSTRAINT PK_JOB_INSTANCE_PARAMETER PRIMARY KEY(ID)
);
CREATE INDEX IDX_FK_JIP_1 ON JOB_INSTANCE_PARAMETER(JOB_INSTANCE);

CREATE MEMORY TABLE MESSAGE
(
	ID INTEGER NOT NULL,
	JOB_INSTANCE INTEGER NOT NULL,
	TEXT_MESSAGE VARCHAR(1000) NOT NULL,
	
	CONSTRAINT PK_MESSAGE PRIMARY KEY(ID)
);
CREATE INDEX IDX_FK_MESSAGE_1 ON MESSAGE(JOB_INSTANCE);

/* JNDI registry */
CREATE MEMORY TABLE JNDI_OBJECT_RESOURCE
(
	ID INTEGER NOT NULL,
	AUTH VARCHAR(20),
	DESCRIPTION VARCHAR(250),
	FACTORY VARCHAR(100) NOT NULL,
	LAST_MODIFIED TIMESTAMP NULL,
	NAME VARCHAR(100) NOT NULL,
	SINGLETON BOOLEAN,
	TEMPLATE VARCHAR(50),
	TYPE VARCHAR(100) NOT NULL,
	
	CONSTRAINT PK_JNDI_OBJECT_RESOURCE PRIMARY KEY(ID),
	CONSTRAINT UK_JNDI_OBJECT_RESOURCE UNIQUE(NAME)
);

CREATE MEMORY TABLE JNDI_OR_PARAMETER
(
	ID INTEGER NOT NULL,
	KEYNAME VARCHAR(50) NOT NULL,
	LAST_MODIFIED TIMESTAMP NULL,
	VALUE VARCHAR(250) NOT NULL,
	JNDI_OR INTEGER,
	
	CONSTRAINT PK_JNDI_OR_PARAMETER PRIMARY KEY(ID),
	CONSTRAINT UK_JNDI_OR_PARAMETER_1 UNIQUE(KEYNAME, JNDI_OR),
	CONSTRAINT FK_JNDI_OR_PARAMETER_1 FOREIGN KEY(JNDI_OR) REFERENCES JNDI_OBJECT_RESOURCE(ID) ON DELETE CASCADE
);
CREATE INDEX IDX_FK_JNDI_OR_PARAMETER_1 ON JNDI_OR_PARAMETER(JNDI_OR);

/* Security */
CREATE MEMORY TABLE PKI
(
	ID INTEGER NOT NULL,
	PEM_CERT VARCHAR(4000) NOT NULL,
	PEM_PK VARCHAR(4000) NOT NULL,
	PRETTY_NAME VARCHAR(100) NOT NULL,
	
	CONSTRAINT PK_PKI PRIMARY KEY(ID),
	CONSTRAINT UK_PKI_1 UNIQUE(PRETTY_NAME)
);

CREATE MEMORY TABLE RROLE
(
	ID INTEGER NOT NULL,
	DESCRIPTION VARCHAR(254) NOT NULL,
	NAME VARCHAR(100) NOT NULL,
	
	CONSTRAINT PK_RROLE PRIMARY KEY(ID),
	CONSTRAINT UK_RROLE_1 UNIQUE(NAME)
);

CREATE MEMORY TABLE RPERMISSION
(
	ID INTEGER NOT NULL,
	NAME VARCHAR(254) NOT NULL,
	ROLE INTEGER NOT NULL,
	
	CONSTRAINT PK_RPERMISSION PRIMARY KEY(ID),
	CONSTRAINT FK_RPERMISSION_1 FOREIGN KEY(ROLE) REFERENCES RROLE(ID) ON DELETE CASCADE
);
CREATE INDEX IDX_FK_RPERMISSION_1 ON RPERMISSION(ROLE);

CREATE MEMORY TABLE RUSER
(
	ID INTEGER NOT NULL,
	CREATION_DATE TIMESTAMP NOT NULL,
	EMAIL VARCHAR(254),
	EXPIRATION_DATE TIMESTAMP NULL,
	FREETEXT VARCHAR(254),
	HASHSALT VARCHAR(254),
	INTERNAL BOOLEAN,
	LAST_MODIFIED TIMESTAMP NOT NULL,
	LOCKED BOOLEAN NOT NULL,
	LOGIN VARCHAR(100) NOT NULL,
	PASSWORD VARCHAR(254),
	
	CONSTRAINT PK_RUSER PRIMARY KEY(ID),
	CONSTRAINT UK_RUSER_1 UNIQUE(LOGIN)
);

CREATE MEMORY TABLE RROLE_RUSER
(
	ID INTEGER NOT NULL, /* not actually needed, but simplifies things Java-side */
	ROLE INTEGER NOT NULL,
	ACCOUNT INTEGER NOT NULL, /* USER is a reserved keyword */
	
	CONSTRAINT PK_RROLE_RUSER PRIMARY KEY(ID),
	CONSTRAINT UK_RROLE_RUSER_1 UNIQUE(ROLE, ACCOUNT),
	CONSTRAINT FK_RROLE_RUSER_1 FOREIGN KEY(ROLE) REFERENCES RROLE(ID) ON DELETE CASCADE,
	CONSTRAINT FK_RROLE_RUSER_2 FOREIGN KEY(ACCOUNT) REFERENCES RUSER(ID) ON DELETE CASCADE
);
CREATE INDEX IDX_FK_RROLE_RUSER_1 ON RROLE_RUSER(ROLE);
CREATE INDEX IDX_FK_RROLE_RUSER_2 ON RROLE_RUSER(ACCOUNT);

/* Misc */
CREATE MEMORY TABLE GLOBAL_PARAMETER
(
	ID INTEGER NOT NULL,
	KEYNAME VARCHAR(50) NOT NULL,
	LAST_MODIFIED TIMESTAMP NOT NULL,
	VALUE VARCHAR(1000) NOT NULL,
	
	CONSTRAINT PK_GLOBAL_PARAMETER PRIMARY KEY(ID),
	CONSTRAINT UK_GLOBAL_PARAMETER_1 UNIQUE(KEYNAME)
);

CREATE MEMORY TABLE WITNESS
(
	ID INTEGER NOT NULL,
	KEYNAME VARCHAR(20) NOT NULL,
	NODE INTEGER NULL,
	LATEST_CONTACT TIMESTAMP NULL,
	
	CONSTRAINT PK_WITNESS PRIMARY KEY(ID),
	CONSTRAINT UK_WITNESS_1 UNIQUE(KEYNAME)
);