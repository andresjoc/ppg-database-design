/*==============================================================*/
/* DBMS name:      PostgreSQL 9.x                               */
/* Created on:     22/04/2026 2:40:07�p.�m.                     */
/*==============================================================*/



/*==============================================================*/
/* Table: ALERT                                                 */
/*==============================================================*/
create table ALERT (
   ID_ALERT             INT4                 not null,
   ID_SESSION           INT4                 not null,
   ID_SEVERITY_LEVEL_   INT4                 null,
   DESCRIPTION          VARCHAR(255)         not null,
   CREATED_AT           DATE                 null,
   UPDATED_AT           DATE                 null,
   constraint PK_ALERT primary key (ID_ALERT)
);

comment on table ALERT is
'Alert type based on measurement';

comment on column ALERT.CREATED_AT is
'Audit Fields';

comment on column ALERT.UPDATED_AT is
'Audit Fields';

/*==============================================================*/
/* Index: ALERT_PK                                              */
/*==============================================================*/
create unique index ALERT_PK on ALERT (
ID_ALERT
);

/*==============================================================*/
/* Index: MONITORING_SESSION_ALERT_FK                           */
/*==============================================================*/
create  index MONITORING_SESSION_ALERT_FK on ALERT (
ID_SESSION
);

/*==============================================================*/
/* Index: SEVERITY_LEVEL_ALERT_FK                               */
/*==============================================================*/
create  index SEVERITY_LEVEL_ALERT_FK on ALERT (
ID_SEVERITY_LEVEL_
);

/*==============================================================*/
/* Table: CITY                                                  */
/*==============================================================*/
create table CITY (
   ID_CITY              INT4                 not null,
   ID_COUNTRY           INT4                 not null,
   NAME                 VARCHAR(100)         not null,
   constraint PK_CITY primary key (ID_CITY)
);

comment on table CITY is
'City Catalog';

/*==============================================================*/
/* Index: CITY_PK                                               */
/*==============================================================*/
create unique index CITY_PK on CITY (
ID_CITY
);

/*==============================================================*/
/* Index: COUNTRY_CITY_FK                                       */
/*==============================================================*/
create  index COUNTRY_CITY_FK on CITY (
ID_COUNTRY
);

/*==============================================================*/
/* Table: COMPUTE_STATUS                                        */
/*==============================================================*/
create table COMPUTE_STATUS (
   ID_COMPUTE_STATUS    INT8                 not null,
   NAME                 VARCHAR(50)          not null,
   DESCRIPTION          VARCHAR(255)         not null,
   constraint PK_COMPUTE_STATUS primary key (ID_COMPUTE_STATUS)
);

comment on table COMPUTE_STATUS is
'Catalog of the processing status of a monitoring session.';

/*==============================================================*/
/* Index: COMPUTE_STATUS_PK                                     */
/*==============================================================*/
create unique index COMPUTE_STATUS_PK on COMPUTE_STATUS (
ID_COMPUTE_STATUS
);

/*==============================================================*/
/* Table: COUNTRY                                               */
/*==============================================================*/
create table COUNTRY (
   ID_COUNTRY           INT4                 not null,
   NAME                 VARCHAR(100)         not null,
   constraint PK_COUNTRY primary key (ID_COUNTRY)
);

comment on table COUNTRY is
'Country Catalog';

/*==============================================================*/
/* Index: COUNTRY_PK                                            */
/*==============================================================*/
create unique index COUNTRY_PK on COUNTRY (
ID_COUNTRY
);

/*==============================================================*/
/* Table: HEALTH_RECORD                                         */
/*==============================================================*/
create table HEALTH_RECORD (
   ID_HEALTH_RECORD     INT4                 not null,
   ID_USER              INT4                 null,
   WEIGHT_KG            DECIMAL(5,2)         not null,
   _HEIGHT_CM           DECIMAL(5,1)         null,
   RECORDED_AT          DATE                 not null,
   constraint PK_HEALTH_RECORD primary key (ID_HEALTH_RECORD)
);

comment on table HEALTH_RECORD is
'User weight and height history';

comment on column HEALTH_RECORD.WEIGHT_KG is
'Current weight (kg)';

/*==============================================================*/
/* Index: HEALTH_RECORD_PK                                      */
/*==============================================================*/
create unique index HEALTH_RECORD_PK on HEALTH_RECORD (
ID_HEALTH_RECORD
);

/*==============================================================*/
/* Index: USER_USER_HEALTH_RECORD_FK                            */
/*==============================================================*/
create  index USER_USER_HEALTH_RECORD_FK on HEALTH_RECORD (
ID_USER
);

/*==============================================================*/
/* Table: MEASUREMENT                                           */
/*==============================================================*/
create table MEASUREMENT (
   ID_MEASUREMENT       INT4                 not null,
   ID_METRIC_TYPE       INT4                 not null,
   ID_SESSION           INT4                 null,
   VALUE                DECIMAL(10,4)        null,
   ALERT_MESSAGE        VARCHAR(255)         null,
   RECORDED_AT          DATE                 not null,
   constraint PK_MEASUREMENT primary key (ID_MEASUREMENT)
);

comment on table MEASUREMENT is
'Table that stores recorded metrics, which can be of different types.';

comment on column MEASUREMENT.ALERT_MESSAGE is
'Alert or error message explaining why it was not possible to calculate the value';

/*==============================================================*/
/* Index: MEASUREMENT_PK                                        */
/*==============================================================*/
create unique index MEASUREMENT_PK on MEASUREMENT (
ID_MEASUREMENT
);

/*==============================================================*/
/* Index: METRIC_TYPE_MEASUREMENT_FK                            */
/*==============================================================*/
create  index METRIC_TYPE_MEASUREMENT_FK on MEASUREMENT (
ID_METRIC_TYPE
);

/*==============================================================*/
/* Index: SESSION_MEASUREMENT_FK                                */
/*==============================================================*/
create  index SESSION_MEASUREMENT_FK on MEASUREMENT (
ID_SESSION
);

/*==============================================================*/
/* Table: METRIC_TYPE                                           */
/*==============================================================*/
create table METRIC_TYPE (
   ID_METRIC_TYPE       INT4                 not null,
   UNIT                 VARCHAR(20)          not null,
   MIN_VALUE            DECIMAL(5,2)         null,
   MAX_VALUE            DECIMAL(5,2)         null,
   IS_DERIVED           BOOL                 null,
   NAME                 VARCHAR(255)         not null,
   constraint PK_METRIC_TYPE primary key (ID_METRIC_TYPE),
   constraint AK_AK_METRIC_TYPE_NAM_METRIC_T unique (NAME)
);

comment on table METRIC_TYPE is
'Metric Catalog';

/*==============================================================*/
/* Index: METRIC_TYPE_PK                                        */
/*==============================================================*/
create unique index METRIC_TYPE_PK on METRIC_TYPE (
ID_METRIC_TYPE
);

/*==============================================================*/
/* Table: MONITORING_SESSION                                    */
/*==============================================================*/
create table MONITORING_SESSION (
   ID_SESSION           INT4                 not null,
   ID_USER              INT4                 not null,
   ID_COMPUTE_STATUS    INT8                 null,
   DATE_TIME            DATE                 not null,
   CREATED_AT           DATE                 null,
   UPDATED_AT           DATE                 null,
   IS_DELTA_ENCODED     BOOL                 null,
   ATRIAL_FIBRILLATION_PRESENT BOOL                 null,
   AF_CONFIDENCE_SCORE  DECIMAL(4,3)         null,
   constraint PK_MONITORING_SESSION primary key (ID_SESSION)
);

comment on column MONITORING_SESSION.CREATED_AT is
'Audit Fields';

comment on column MONITORING_SESSION.UPDATED_AT is
'Audit Fields';

/*==============================================================*/
/* Index: MONITORING_SESSION_PK                                 */
/*==============================================================*/
create unique index MONITORING_SESSION_PK on MONITORING_SESSION (
ID_SESSION
);

/*==============================================================*/
/* Index: USER_SESSION_FK                                       */
/*==============================================================*/
create  index USER_SESSION_FK on MONITORING_SESSION (
ID_USER
);

/*==============================================================*/
/* Index: MONITORING_SIN_C_S_FK                                 */
/*==============================================================*/
create  index MONITORING_SIN_C_S_FK on MONITORING_SESSION (
ID_COMPUTE_STATUS
);

/*==============================================================*/
/* Table: PPG_SAMPLE                                            */
/*==============================================================*/
create table PPG_SAMPLE (
   ID_PPG_SAMPLE        INT8                 not null,
   ID_SESSION           INT4                 null,
   TS         INT8                 null,
   GREEN_               INT4                 not null,
   RED_                 INT4                 null,
   IR                   INT4                 null,
   constraint PK_PPG_SAMPLE primary key (ID_PPG_SAMPLE)
);

comment on table PPG_SAMPLE is
'PPG signal sample.';

/*==============================================================*/
/* Index: PPG_SAMPLE_PK                                         */
/*==============================================================*/
create unique index PPG_SAMPLE_PK on PPG_SAMPLE (
ID_PPG_SAMPLE
);

/*==============================================================*/
/* Index: MS_PPG_SAMPLE_FK                                      */
/*==============================================================*/
create  index MS_PPG_SAMPLE_FK on PPG_SAMPLE (
ID_SESSION
);

/*==============================================================*/
/* Table: SEVERITY_LEVEL                                        */
/*==============================================================*/
create table SEVERITY_LEVEL (
   ID_SEVERITY_LEVEL_   INT4                 not null,
   DESCRIPTION          VARCHAR(255)         null,
   NAME                 VARCHAR(255)         not null,
   constraint PK_SEVERITY_LEVEL primary key (ID_SEVERITY_LEVEL_),
   constraint AK_AK_SEVERITY_LEVEL__SEVERITY unique (NAME)
);

/*==============================================================*/
/* Index: SEVERITY_LEVEL_PK                                     */
/*==============================================================*/
create unique index SEVERITY_LEVEL_PK on SEVERITY_LEVEL (
ID_SEVERITY_LEVEL_
);

/*==============================================================*/
/* Table: "USER"                                                */
/*==============================================================*/
create table "USER" (
   ID_USER              INT4                 not null,
   ID_CITY              INT4                 null,
   EMAIL                VARCHAR(50)          not null,
   PASSWORD_HASH        VARCHAR(255)         not null,
   FIRST_NAME           VARCHAR(50)          not null,
   LAST_NAME            VARCHAR(50)          not null,
   BIRTH_DATE           DATE                 not null,
   CREATED_AT           DATE                 null,
   UPDATED_AT           DATE                 null,
   constraint PK_USER primary key (ID_USER),
   constraint AK_AK_USER_EMAIL_USER unique (EMAIL)
);

comment on table "USER" is
'Table that stores basic system user information';

comment on column "USER".CREATED_AT is
'Audit Fields';

comment on column "USER".UPDATED_AT is
'Audit Fields';

/*==============================================================*/
/* Index: USER_PK                                               */
/*==============================================================*/
create unique index USER_PK on "USER" (
ID_USER
);

/*==============================================================*/
/* Index: USER_CITY_FK                                          */
/*==============================================================*/
create  index USER_CITY_FK on "USER" (
ID_CITY
);

/*==============================================================*/
/* Table: WEARABLE                                              */
/*==============================================================*/
create table WEARABLE (
   ID_WEARABLE          INT4                 not null,
   ID_USER              INT4                 null,
   ID_WEARABLE_STATUS   INT4                 null,
   ID_WEARABLE_MODEL    INT4                 null,
   MAC_ADDRESS          VARCHAR(17)          null,
   CREATED_AT           DATE                 not null,
   UPDATED_AT           DATE                 null,
   constraint PK_WEARABLE primary key (ID_WEARABLE)
);

comment on table WEARABLE is
'Table that stores information about the equipment related to the user';

comment on column WEARABLE.MAC_ADDRESS is
'Wearable MAC Address.';

comment on column WEARABLE.CREATED_AT is
'Audit Fields';

comment on column WEARABLE.UPDATED_AT is
'Audit Fields';

/*==============================================================*/
/* Index: WEARABLE_PK                                           */
/*==============================================================*/
create unique index WEARABLE_PK on WEARABLE (
ID_WEARABLE
);

/*==============================================================*/
/* Index: WEARABLE_USER_FK                                      */
/*==============================================================*/
create  index WEARABLE_USER_FK on WEARABLE (
ID_USER
);

/*==============================================================*/
/* Index: STATUS_WEARABLE_FK                                    */
/*==============================================================*/
create  index STATUS_WEARABLE_FK on WEARABLE (
ID_WEARABLE_STATUS
);

/*==============================================================*/
/* Index: MODEL_WEARABLE_FK                                     */
/*==============================================================*/
create  index MODEL_WEARABLE_FK on WEARABLE (
ID_WEARABLE_MODEL
);

/*==============================================================*/
/* Table: WEARABLE_MODEL                                        */
/*==============================================================*/
create table WEARABLE_MODEL (
   ID_WEARABLE_MODEL    INT4                 not null,
   BRAND                VARCHAR(50)          not null,
   MODEL                VARCHAR(50)          null,
   constraint PK_WEARABLE_MODEL primary key (ID_WEARABLE_MODEL)
);

comment on table WEARABLE_MODEL is
'Table that stores information regarding the types of equipment that can be registered.';

/*==============================================================*/
/* Index: WEARABLE_MODEL_PK                                     */
/*==============================================================*/
create unique index WEARABLE_MODEL_PK on WEARABLE_MODEL (
ID_WEARABLE_MODEL
);

/*==============================================================*/
/* Table: WEARABLE_STATUS                                       */
/*==============================================================*/
create table WEARABLE_STATUS (
   ID_WEARABLE_STATUS   INT4                 not null,
   NAME                 VARCHAR(20)          not null,
   DESCRIPTION          VARCHAR(255)         null,
   constraint PK_WEARABLE_STATUS primary key (ID_WEARABLE_STATUS)
);

comment on table WEARABLE_STATUS is
'Wearable Status Catalog, Expected statuses: ACTIVE (in use), INACTIVE (not in use), DISCONNECTED (no BT signal), MAINTENANCE (under review)';

/*==============================================================*/
/* Index: WEARABLE_STATUS_PK                                    */
/*==============================================================*/
create unique index WEARABLE_STATUS_PK on WEARABLE_STATUS (
ID_WEARABLE_STATUS
);

alter table ALERT
   add constraint FK_ALERT_MONITORIN_MONITORI foreign key (ID_SESSION)
      references MONITORING_SESSION (ID_SESSION)
      on delete restrict on update restrict;

alter table ALERT
   add constraint FK_ALERT_SEVERITY__SEVERITY foreign key (ID_SEVERITY_LEVEL_)
      references SEVERITY_LEVEL (ID_SEVERITY_LEVEL_)
      on delete restrict on update restrict;

alter table CITY
   add constraint FK_CITY_COUNTRY_C_COUNTRY foreign key (ID_COUNTRY)
      references COUNTRY (ID_COUNTRY)
      on delete restrict on update restrict;

alter table HEALTH_RECORD
   add constraint FK_HEALTH_R_USER_USER_USER foreign key (ID_USER)
      references "USER" (ID_USER)
      on delete restrict on update restrict;

alter table MEASUREMENT
   add constraint FK_MEASUREM_METRIC_TY_METRIC_T foreign key (ID_METRIC_TYPE)
      references METRIC_TYPE (ID_METRIC_TYPE)
      on delete restrict on update restrict;

alter table MEASUREMENT
   add constraint FK_MEASUREM_SESSION_M_MONITORI foreign key (ID_SESSION)
      references MONITORING_SESSION (ID_SESSION)
      on delete restrict on update restrict;

alter table MONITORING_SESSION
   add constraint FK_MONITORI_COMPUTE_M_COMPUTE_ foreign key (ID_COMPUTE_STATUS)
      references COMPUTE_STATUS (ID_COMPUTE_STATUS)
      on delete restrict on update restrict;

alter table MONITORING_SESSION
   add constraint FK_MONITORI_USER_SESS_USER foreign key (ID_USER)
      references "USER" (ID_USER)
      on delete restrict on update restrict;

alter table PPG_SAMPLE
   add constraint FK_PPG_SAMP_MS_PPG_SA_MONITORI foreign key (ID_SESSION)
      references MONITORING_SESSION (ID_SESSION)
      on delete restrict on update restrict;

alter table "USER"
   add constraint FK_USER_USER_CITY_CITY foreign key (ID_CITY)
      references CITY (ID_CITY)
      on delete restrict on update restrict;

alter table WEARABLE
   add constraint FK_WEARABLE_MODEL_WEA_WEARABLE foreign key (ID_WEARABLE_MODEL)
      references WEARABLE_MODEL (ID_WEARABLE_MODEL)
      on delete restrict on update restrict;

alter table WEARABLE
   add constraint FK_WEARABLE_STATUS_WE_WEARABLE foreign key (ID_WEARABLE_STATUS)
      references WEARABLE_STATUS (ID_WEARABLE_STATUS)
      on delete restrict on update restrict;

alter table WEARABLE
   add constraint FK_WEARABLE_WEARABLE__USER foreign key (ID_USER)
      references "USER" (ID_USER)
      on delete restrict on update restrict;

