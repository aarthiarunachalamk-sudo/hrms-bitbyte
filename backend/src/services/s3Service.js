const cloudinary = require('cloudinary').v2;

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

async function uploadSelfie(file, employeeId, eventType) {
  if (!file || !file.buffer) {
    throw new Error('No file buffer provided for upload');
  }

  const publicId = `selfie_${employeeId}_${eventType}_${Date.now()}`;

  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      {
        folder: 'hrms_selfies',
        public_id: publicId,
        resource_type: 'image',
      },
      (error, result) => {
        if (error) {
          console.error('Cloudinary upload failed:', error.message);
          return reject(error);
        }
        console.log(`Selfie uploaded to Cloudinary: ${result.secure_url}`);
        resolve(result.secure_url);
      }
    );
    stream.end(file.buffer);
  });
}

module.exports = {
  uploadSelfie,
};