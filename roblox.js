const { SlashCommandBuilder, EmbedBuilder } = require("discord.js");
const axios = require("axios");

module.exports = {
  data: new SlashCommandBuilder()
    .setName("roblox")
    .setDescription("Get Roblox user stats")
    .addStringOption(option =>
      option.setName("username")
        .setDescription("Roblox username")
        .setRequired(true)
    ),

  async execute(interaction) {
    const username = interaction.options.getString("username");

    try {
      // Get user ID
      const userRes = await axios.post(
        "https://users.roblox.com/v1/usernames/users",
        { usernames: [username] }
      );

      const user = userRes.data.data[0];
      if (!user) return interaction.reply("❌ User not found");

      // Get user info
      const infoRes = await axios.get(
        `https://users.roblox.com/v1/users/${user.id}`
      );

      // Get avatar
      const avatarRes = await axios.get(
        `https://thumbnails.roblox.com/v1/users/avatar?userIds=${user.id}&size=420x420&format=Png&isCircular=false`
      );

      const avatar = avatarRes.data.data[0].imageUrl;

      const embed = new EmbedBuilder()
        .setTitle(infoRes.data.name)
        .setThumbnail(avatar)
        .addFields(
          { name: "🆔 User ID", value: `${infoRes.data.id}`, inline: true },
          { name: "📅 Created", value: infoRes.data.created, inline: true }
        )
        .setColor("Blue");

      await interaction.reply({ embeds: [embed] });

    } catch (err) {
      console.error(err);
      interaction.reply("⚠️ Error fetching Roblox data.");
    }
  }
};