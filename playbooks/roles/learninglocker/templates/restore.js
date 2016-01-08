var db = db.getSiblingDB('learninglocker');

var updateAdmin = {
  email: '{{learninglocker__admin_email}}',
  name: '{{learninglocker__admin_user}}'
};

var updateClient = {
  'api.basic_key': '{{learninglocker__xapi_user}}',
  'api.basic_secret': '{{learninglocker__xapi_pass}}',
};

var updateLRS = {
  title: '{{learninglocker__lrs_name}}',
  description: '{{learninglocker__lrs_description}}',
  'users.0.email': updateAdmin.email,
  'users.0.name': updateAdmin.name
};

db.users.update({ _id: ObjectId("555dd843b30b0d4f9a0041a7") }, { $set: updateAdmin });

db.client.update({_id: ObjectId("557c3f51b30b0d3d2c0041a7") }, { $set: updateClient });

db.lrs.update({ _id : ObjectId("555dd9c6b30b0d4f9a0041aa") }, { $set: updateLRS });