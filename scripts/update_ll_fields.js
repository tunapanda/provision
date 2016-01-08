var db = db.getSiblingDB('learninglocker');

var updateAdmin = {
  email: 'vagrant@swag.testing.tunapanda.org',
  name: 'vagrant'
};

var updateClient = {
  'api.basic_key': 'caae95f54d6545c76fc289f02a3c1d51c455f7e6',
  'api.basic_secret': '40cb0287f95189298729f6ccc36f6277840604ad',
};

var updateLRS = {
  title: 'Swag',
  description: 'Swag!',
  'users.0.email': updateAdmin.email,
  'users.0.name': updateAdmin.name
};

db.users.update({ _id: ObjectId("555dd843b30b0d4f9a0041a7") }, { $set: updateAdmin });

db.client.update({_id: ObjectId("557c3f51b30b0d3d2c0041a7") }, { $set: updateClient });

db.lrs.update({ _id : ObjectId("555dd9c6b30b0d4f9a0041aa") }, { $set: updateLRS });